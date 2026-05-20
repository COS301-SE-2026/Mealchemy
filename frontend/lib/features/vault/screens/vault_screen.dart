import 'package:flutter/material.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vault')),
      body: const Center(child: Text('Vault Screen')),
    );
  }
}