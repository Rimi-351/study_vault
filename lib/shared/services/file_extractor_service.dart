import 'dart:io';
import 'dart:convert'; // ✅ For decoding Cloudmersive JSON
import 'package:http/http.dart' as htp; // ✅ For Cloudmersive API
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; // ✅ For Images
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart'; // ✅ For PDFs
import 'package:flutter/foundation.dart';
import '../models/file_model.dart';

class FileExtractorService {
  static const String _defaultCloudmersiveApiKey = String.fromEnvironment('CLOUDMERSIVE_API_KEY');
  static String? _testApiKeyOverride;

  /// Allows test injection to verify missing/empty key validation
  @visibleForTesting
  static void setApiKeyForTesting(String? key) {
    _testApiKeyOverride = key;
  }

  /// Resets test injection state back to compile-time environment
  @visibleForTesting
  static void resetTestingState() {
    _testApiKeyOverride = null;
  }

  static String get _effectiveApiKey => (_testApiKeyOverride ?? _defaultCloudmersiveApiKey).trim();

  static Future<ExtractedFile?> pickAndExtract() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // ✅ Supports PDF, Text, Office, and Images
      allowedExtensions: [
        'pdf', 'txt', 'csv',
        'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 
        'jpg', 'jpeg', 'png'
      ], 
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final name = result.files.single.name;
    final extension = name.split('.').last.toLowerCase();

    try {
      String text = '';

      // 1. PDF (Local - Uses your improved Loop method)
      if (extension == 'pdf') {
        text = await _extractPdfText(file);
      } 
      // 2. IMAGES (Local - OCR)
      else if (['jpg', 'jpeg', 'png'].contains(extension)) {
        text = await _extractImageText(file);
      } 
      // 3. TEXT / CSV (Local)
      else if (extension == 'txt' || extension == 'csv') {
        text = await file.readAsString();
      } 
      // 4. OFFICE FILES (Online - Cloudmersive)
      else if (['doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'].contains(extension)) {
        text = await _extractOfficeTextOnline(file);
      }

      if (text.trim().isEmpty) {
        text = "[Error: File appears empty or text could not be extracted]";
      }

      return ExtractedFile(
        id: const Uuid().v4(),
        originalName: name,
        extractedText: text.trim(),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("File extraction error: $e");
      }
      return null;
    }
  }

  // --- ☁️ ONLINE OFFICE EXTRACTION (Cloudmersive) ---
  static Future<String> _extractOfficeTextOnline(File file) async {
    final apiKey = _effectiveApiKey;
    if (apiKey.isEmpty || apiKey.contains('PASTE_YOUR')) {
      return "Configuration Error: Cloudmersive API key is missing or not configured via --dart-define or --dart-define-from-file.";
    }

    try {
      // API Endpoint for "Autodetect to Text"
      var uri = Uri.parse('https://api.cloudmersive.com/convert/autodetect/to/txt');
      var request = htp.MultipartRequest('POST', uri);
      
      // Add Headers
      request.headers['Apikey'] = apiKey;
      
      // Add File
      request.files.add(await htp.MultipartFile.fromPath('inputFile', file.path));

      // Send Request
      var streamedResponse = await request.send();
      var response = await htp.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        // Cloudmersive returns JSON with "TextResult"
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['TextResult'] ?? "No text found in this document.";
      } else {
        if (kDebugMode) {
          debugPrint("Cloudmersive HTTP error: ${response.statusCode}");
        }
        return "Failed to convert file online. Please try another file format.";
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Cloudmersive error: $e");
      }
      return "Online document conversion failed. Please check your network and try again.";
    }
  }

  // --- 📱 LOCAL PDF READER (Improved Loop Method Preserved) ---
  static Future<String> _extractPdfText(File file) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());
      String fullText = '';
      
      // ✅ This is the robust loop from your previous code
      for (int i = 0; i < document.pages.count; i++) {
        String pageText = PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
        fullText += "$pageText\n\n";
      }
      
      document.dispose();
      return fullText.trim();
    } catch (e) {
      return "Error reading PDF: $e";
    }
  }

  // --- 📱 LOCAL IMAGE READER (OCR) ---
  static Future<String> _extractImageText(File file) async {
    try {
      final inputImage = InputImage.fromFile(file);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String text = recognizedText.text;
      await textRecognizer.close();
      return text;
    } catch (e) {
      return "Error reading Image: $e";
    }
  }

  // --- 💾 LOCAL SAVE UTILITY (Preserved) ---
  static Future<String?> saveExtractedTextFile(ExtractedFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${file.id}_extracted.txt';
    await File(path).writeAsString(file.extractedText);
    return path;
  }
}