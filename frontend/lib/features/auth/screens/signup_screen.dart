//handles ui signup
import 'package:flutter/material.dart';
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: const Center(child: Text('Signup Screen')),
    );
  }
}