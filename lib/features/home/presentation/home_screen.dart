import 'package:flutter/material.dart';
import 'package:study_vault/features/chat/presentation/screen/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("StudyVault"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 30),
            const Text("AI Study Assistant Ready", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
              icon: const Icon(Icons.chat),
              label: const Text("Start AI Chat", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}