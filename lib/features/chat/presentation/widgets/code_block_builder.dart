import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/dracula.dart';

// 1. The Builder Class (Detects code blocks)
class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';
    if (element.attributes['class'] != null) {
      String lg = element.attributes['class']!;
      language = lg.substring(9);
    }
    if (language.isEmpty && element.textContent.contains("\n")) {
      language = 'plaintext';
    }

    return CodeBlockWrapper(
      codeContent: element.textContent,
      language: language,
    );
  }
}

// 2. The Visual Widget (Colors + Copy Button)
class CodeBlockWrapper extends StatelessWidget {
  final String codeContent;
  final String language;

  const CodeBlockWrapper(
      {super.key, required this.codeContent, required this.language});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: HighlightView(
              codeContent,
              language: language,
              theme: draculaTheme,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: codeContent));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Code copied!'),
                  duration: Duration(milliseconds: 600),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.content_copy, color: Colors.white70, size: 16),
                  SizedBox(width: 4),
                  Text("Copy", style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}