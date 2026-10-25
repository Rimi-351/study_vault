import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ Services
import '../../../../shared/services/gemini_service.dart';
import '../../../../shared/models/file_model.dart';
import '../../services/chat_pdf_service.dart'; // ✅ PDF Service

// ✅ Widgets (The files you just created)
import '../widgets/chat_input_area.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? _currentChatId;
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final isFarFromBottom = _scrollController.position.maxScrollExtent -
            _scrollController.offset > 300;
    if (isFarFromBottom != _showScrollButton) {
      setState(() {
        _showScrollButton = isFarFromBottom;
      });
    }
  }

  // --- LOGIC: CHAT HISTORY ---
  void _startNewChat() {
    setState(() {
      _currentChatId = null;
      _messages.clear();
      _messages.add({
        'role': 'model',
        'text': 'Hello! I am your Study Assistant. Ask me anything or upload a file.'
      });
    });
    Navigator.pop(context); // Close Drawer
  }

  void _loadChatHistory(String chatId, List<dynamic> oldMessages) {
    setState(() {
      _currentChatId = chatId;
      _messages.clear();
      for (var msg in oldMessages) {
        _messages.add(msg as Map<String, dynamic>);
      }
    });
    Navigator.pop(context); // Close Drawer
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  // --- LOGIC: SEND MESSAGE ---
  Future<void> _handleSendMessage(String text, ExtractedFile? file) async {
    final userMsg = {
      'role': 'user',
      'text': text,
      'fileName': file?.originalName,
    };

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      String fullPrompt = "";
      if (file != null) {
        fullPrompt = """
You are an expert Study Assistant. 
The user has uploaded a PDF/Image content.
RULES:
1. REPAIR text (join split letters).
2. EXPLAIN content.
3. FORMAT with Markdown.
4. CODE: Use code blocks.
USER QUESTION: $text
[DOCUMENT CONTEXT]:
${file.extractedText}
""";
      } else {
        fullPrompt = text;
      }

      // Call Service
      final responseText = await GeminiService.sendMessage(fullPrompt);

      setState(() {
        _isTyping = false;
        _messages.add({'role': 'model', 'text': responseText});
      });
      _scrollToBottom();
      await _saveChatToFirestore();

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Chat error: $e');
      }
      final errorMessage = (e is StateError)
          ? e.message
          : 'Failed to generate a response. Please check your network connection and try again.';
      setState(() {
        _isTyping = false;
        _messages.add({'role': 'error', 'text': errorMessage});
      });
    }
  }

  Future<void> _saveChatToFirestore() async {
    if (_userId.isEmpty) return;
    final chatData = {
      'updatedAt': FieldValue.serverTimestamp(),
      'title': _messages.length > 1 ? _messages[1]['text'].toString().substring(0, 15) : 'New Chat',
      'messages': _messages,
    };

    if (_currentChatId == null) {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(_userId).collection('chats').add(chatData);
      _currentChatId = doc.id;
    } else {
      await FirebaseFirestore.instance
          .collection('users').doc(_userId).collection('chats').doc(_currentChatId).update(chatData);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ✅ THE UI BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ChatDrawer(
        onNewChat: _startNewChat,
        onLoadChat: _loadChatHistory,
      ),
      
      // ✅ APP BAR WITH PDF BUTTON
      appBar: AppBar(
        title: const Text("StudyVault AI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Export Chat to PDF",
            onPressed: () async {
              if (_messages.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No messages to export!')),
                );
                return;
              }
              // ✅ Call the PDF Service
              await ChatPdfService.exportChat(_messages);
            },
          ),
        ],
      ),
      
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      // ✅ Using your split Message Bubble widget
                      return ExpandableMessageBubble(message: _messages[index]);
                    },
                  ),
                ),
                // Jump to bottom button
                if (_showScrollButton)
                  Positioned(
                    bottom: 20, right: 20,
                    child: FloatingActionButton.small(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      elevation: 4,
                      onPressed: _scrollToBottom,
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ),
              ],
            ),
          ),
          if (_isTyping)
            const Padding(padding: EdgeInsets.all(8), child: Text("AI is thinking...")),
          
          // ✅ Using your split Input Area widget
          ChatInputArea(onSend: _handleSendMessage),
        ],
      ),
    );
  }
}