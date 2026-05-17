import 'package:flutter/material.dart';

class PreferenceScreen extends StatelessWidget {
  const PreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preference')),
      body: const Center(child: Text('Preference Screen')),
    );
  }
}