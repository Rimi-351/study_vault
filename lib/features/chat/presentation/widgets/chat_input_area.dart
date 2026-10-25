import 'package:flutter/material.dart';
import '../../../../shared/models/file_model.dart';
import '../../../../shared/services/file_extractor_service.dart';

class ChatInputArea extends StatefulWidget {
  final Function(String text, ExtractedFile? file) onSend;

  const ChatInputArea({super.key, required this.onSend});

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final TextEditingController _controller = TextEditingController();
  ExtractedFile? _pendingFile;
  bool _isLoadingFile = false;

  /// Pick file using your LOCAL Extractor (No Firebase Storage needed)
  Future<void> _pickFile() async {
    setState(() => _isLoadingFile = true);
    
    // Uses the service that reads file from RAM (Safe for no-billing accounts)
    final file = await FileExtractorService.pickAndExtract();
    
    setState(() {
      _pendingFile = file;
      _isLoadingFile = false;
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty && _pendingFile == null) return;

    // Send data to parent
    widget.onSend(text, _pendingFile);

    // Reset UI
    _controller.clear();
    setState(() {
      _pendingFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. THE FILE PREVIEW (Gemini Style)
          if (_isLoadingFile) const LinearProgressIndicator(),
          
          if (_pendingFile != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _pendingFile!.originalName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => setState(() => _pendingFile = null),
                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                  )
                ],
              ),
            ),

          // 2. THE INPUT ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _pickFile,
                icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
                tooltip: "Attach file",
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _controller,
                    // ✅ THIS MAKES IT EXPANDABLE
                    minLines: 1,
                    maxLines: 6, 
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: "Ask something...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  onPressed: _handleSend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}