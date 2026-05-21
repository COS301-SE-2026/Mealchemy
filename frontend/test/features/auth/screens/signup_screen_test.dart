import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/auth/screens/signup_screen.dart';

void main() {
  Widget buildWidget() {
    return MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Text('Login')),
          ),
          GoRoute(
            path: '/preference',
            builder: (context, state) => const Scaffold(body: Text('Preference')),
          ),
        ],
      ),
    );
  }

  group('SignupScreen', () {
    //screen and checking it renders without crashing
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget( buildWidget());
       await tester.pump( );
      expect(find.byType(SignupScreen), findsOneWidget);
    });

    //Rendering a screen and checking Create Account heading appears
    testWidgets('renders Create Account heading', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();
      expect(find.text('Create Account'), findsWidgets);
    });
  });
}