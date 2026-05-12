import 'package:flutter/material.dart';

void main() {
  runApp(const MealchemyApp());
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
