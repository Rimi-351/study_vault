import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'code_block_builder.dart'; 

class ExpandableMessageBubble extends StatefulWidget {
  final Map<String, dynamic> message;
  const ExpandableMessageBubble({super.key, required this.message});

  @override
  State<ExpandableMessageBubble> createState() => _ExpandableMessageBubbleState();
}

class _ExpandableMessageBubbleState extends State<ExpandableMessageBubble> {
  bool _isExpanded = false;
  static const int _charLimit = 250;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.message['text']));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied'), duration: Duration(milliseconds: 600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    final isUser = msg['role'] == 'user';
    final isError = msg['role'] == 'error';
    final String fullText = msg['text'];
    final bool isLong = fullText.length > _charLimit;

    // ✅ FIXED: Now applies to BOTH User and AI
    String textToShow = fullText;
    if (isLong && !_isExpanded) {
      textToShow = "${fullText.substring(0, _charLimit)}...\n";
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.90),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : (isError ? Colors.red.shade100 : Colors.grey[200]),
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : null,
            topLeft: !isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. File Name Attachment
            if (msg['fileName'] != null)
              Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file, size: 14, color: isUser ? Colors.white70 : Colors.black54),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "${msg['fileName']}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isUser ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

            // 2. Markdown Body
            MarkdownBody(
              data: textToShow,
              selectable: true,
              builders: {
                'code': CodeElementBuilder(), 
              },
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15),
                strong: TextStyle(color: isUser ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                code: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                  backgroundColor: isUser ? Colors.white24 : Colors.black12,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            // 3. Read More / Show Less (✅ Enabled for EVERYONE now)
            if (isLong)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Text(
                    _isExpanded ? "Show less" : "Read more",
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // 4. Copy Button (✅ Enabled for EVERYONE now)
            const SizedBox(height: 8),
            Divider(color: isUser ? Colors.white24 : Colors.black12, height: 1),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                InkWell(
                  onTap: _copyToClipboard,
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 14, color: isUser ? Colors.white70 : Colors.black54),
                      const SizedBox(width: 4),
                      Text("Copy", style: TextStyle(fontSize: 12, color: isUser ? Colors.white70 : Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}