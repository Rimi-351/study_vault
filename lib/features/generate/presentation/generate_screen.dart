import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// ✅ IMPORT THE CORRECT SERVICES
import '../../../shared/models/file_model.dart';
import '../../../shared/services/file_extractor_service.dart'; // Use this one, not LocalFileService
import '../../../shared/services/gemini_service.dart';      // Import Gemini

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  ExtractedFile? _currentFile;
  String _generatedContent = '';
  bool _isProcessing = false;

  /// ✅ FIXED: Use FileExtractorService (Real PDF reading)
  Future<void> _pickAndProcessFile() async {
    _setProcessing(true);
    
    try {
      // Use the service that actually reads the PDF text
      final extractedFile = await FileExtractorService.pickAndExtract();
      
      if (extractedFile != null) {
        setState(() {
          _currentFile = extractedFile;
          _generatedContent = ''; // Clear previous results
        });
        
        _showSuccess('File processed! Found ${_currentFile!.extractedText.length} characters.');
      } else {
        // If user cancelled picking
        if (kDebugMode) debugPrint("File picking cancelled or failed.");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('File processing error: $e');
      }
      _showError('Unable to process the selected file. Please verify the file format and try again.');
    } finally {
      _setProcessing(false);
    }
  }

  /// ✅ FIXED: Call Real Gemini API
  Future<void> _generateMCQs() async {
    if (_currentFile == null) {
      _showError('Please select a file first');
      return;
    }

    // Check if text is too short (empty file)
    if (_currentFile!.extractedText.length < 50) {
      _showError('File text is too short or empty. Try a different file.');
      return;
    }

    _setProcessing(true);

    try {
      // 1. Call the REAL Gemini Service
      final result = await GeminiService.generateMCQs(_currentFile!.extractedText);

      // 2. Update State with Real Results
      setState(() {
        _generatedContent = result;
        
        // Update model with the new content
        _currentFile = _currentFile!.copyWith(
          generatedContent: result,
        );
      });

      // 3. Save to History
      await _saveToHistory();
      _showSuccess('MCQs generated successfully!');
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Gemini generation error: $e');
      }
      if (e is StateError) {
        _showError(e.message);
      } else {
        _showError('AI generation failed. Please check your network connection and try again.');
      }
    } finally {
      _setProcessing(false);
    }
  }

  /// Save to Firestore history
  Future<void> _saveToHistory() async {
    if (_currentFile == null) return;
    
    final currentContext = context;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // Don't save if not logged in

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add(_currentFile!.toJson());
          
      if (currentContext.mounted) {
        debugPrint('Saved to history');
      }
    } catch (e) {
      debugPrint('Failed to save history: $e');
    }
  }

  /// Generate & share PDF
  Future<void> _generateAndSharePDF() async {
    if (_currentFile == null || _generatedContent.isEmpty) {
      _showError('Please generate MCQs first');
      return;
    }

    _setProcessing(true);

    try {
      final pdf = pw.Document();
      
      // Split content to handle long text
      //final lines = _generatedContent.split('\n');

      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Text('StudyVault MCQs - ${_currentFile!.originalName}'),
            ),
            pw.Paragraph(
              text: _generatedContent,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      
      final currentContext = context;
      if (currentContext.mounted) {
        await Printing.sharePdf(
          bytes: bytes, 
          filename: '${_currentFile!.originalName}_mcqs.pdf',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PDF export error: $e');
      }
      _showError('Failed to generate or share PDF. Please try again.');
    } finally {
      _setProcessing(false);
    }
  }

  /// Helper methods
  void _setProcessing(bool value) {
    if (mounted) {
      setState(() {
        _isProcessing = value;
      });
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ $message'), backgroundColor: Colors.green),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $message'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("StudyVault - Generate MCQs")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // File Selection
            ElevatedButton.icon(
              onPressed: _pickAndProcessFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Select Study Material (PDF/TXT)"),
            ),
            const SizedBox(height: 10),

            // Processing Indicator
            if (_isProcessing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
            ],

            // File Info
            if (_currentFile != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        "📄 ${_currentFile!.originalName}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Ready to analyze ${_currentFile!.extractedText.length} chars",
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Generate MCQs Button
              ElevatedButton.icon(
                onPressed: _generateMCQs,
                icon: const Icon(Icons.psychology), // Changed icon
                label: const Text("Generate MCQs with AI"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],

            // Generated Content
            if (_generatedContent.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                "Generated MCQs:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Text(_generatedContent),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // Share PDF Button
              ElevatedButton.icon(
                onPressed: _generateAndSharePDF,
                icon: const Icon(Icons.share),
                label: const Text("Download PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}