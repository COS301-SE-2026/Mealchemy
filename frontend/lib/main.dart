import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MealchemyApp()));
}

class MealchemyApp extends StatelessWidget {
  const MealchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mealchemy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}