import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MealchemyApp()));
}

class MealchemyApp extends StatelessWidget {
  const MealchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mealchemy',
      home: Scaffold(
        body: Center(
          child: Text('Mealchemy'),
        ),
      ),
    );
  }
}
