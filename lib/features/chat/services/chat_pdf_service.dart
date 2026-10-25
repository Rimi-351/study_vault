import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // ✅ Needed for temp storage
import 'package:share_plus/share_plus.dart';       // ✅ Needed for WhatsApp/Share sheet
import 'package:flutter/foundation.dart';

class ChatPdfService {
  static Future<void> exportChat(List<Map<String, dynamic>> messages) async {
    if (messages.isEmpty) return;

    final pdf = pw.Document();
    
    // Use standard fonts
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("StudyVault Export", style: pw.TextStyle(font: fontBold, fontSize: 18)),
                  pw.Text(DateTime.now().toString().split('.')[0],
                      style: pw.TextStyle(font: fontRegular, fontSize: 10, color: PdfColors.grey)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            ...messages.map((msg) {
              final isUser = msg['role'] == 'user';
              final text = msg['text'] ?? '';
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: isUser ? PdfColors.blue50 : PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(isUser ? "You" : "AI", style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Text(text, style: pw.TextStyle(font: fontRegular, fontSize: 11)),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    // ✅ NEW LOGIC: Save to Temp -> Share XFile
    try {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/study_vault_chat.pdf");
      await file.writeAsBytes(await pdf.save());

      // Open the System Share Sheet (WhatsApp, Drive, etc.)
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Here is my chat history from StudyVault.',
      );
    } catch (e) {
      debugPrint("Error sharing PDF: $e");
    }
  }
}