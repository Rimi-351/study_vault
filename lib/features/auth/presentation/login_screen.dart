import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_vault/features/home/presentation/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();

      if (!mounted) return; // <-- ensures widget still exists

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Anonymous sign-in error: $e");
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to sign in right now. Please check your network and try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 120, color: Colors.deepPurple),
              const SizedBox(height: 40),
              const Text("Welcome to StudyVault", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Your AI Study Companion", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: _signInAnonymously,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Text("Continue as Guest", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("We'll add Google Sign-In later"),
            ],
          ),
        ),
      ),
    );
  }
}
