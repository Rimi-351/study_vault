import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatDrawer extends StatelessWidget {
  final VoidCallback onNewChat;
  final Function(String id, List<dynamic> messages) onLoadChat;

  const ChatDrawer({
    super.key,
    required this.onNewChat,
    required this.onLoadChat,
  });

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("StudyVault History"),
            accountEmail: Text(userId.isEmpty ? "Guest" : "Logged In"),
            currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white, child: Icon(Icons.history)),
            decoration: const BoxDecoration(color: Colors.deepPurple),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("New Chat"),
            onTap: onNewChat,
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('chats')
                  .orderBy('updatedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    // Helper to shorten title
                    String title = data['title'] ?? 'Chat';
                    if (title.length > 30) title = '${title.substring(0, 30)}...';

                    return ListTile(
                      leading: const Icon(Icons.message, size: 18),
                      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => onLoadChat(docs[index].id, data['messages'] ?? []),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}