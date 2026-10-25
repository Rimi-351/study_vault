import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_vault/features/home/presentation/home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return; // <-- ensures widget is still in tree

    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text("StudyVault", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
