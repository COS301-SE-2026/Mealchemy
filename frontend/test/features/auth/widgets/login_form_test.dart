import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/auth/widgets/login_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  //Helper function to build the widget with necessary routing for last test loading state
  Widget buildWidget() {
  return ProviderScope(
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: SingleChildScrollView(child: LoginForm()),
            ),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const Scaffold(
              body: Text('Dashboard'),
            ),
          ),
        ],
      ),
    ),
  );
}

  group('LoginForm', () {
    //Building login form 
    //checking if the title appears 
    testWidgets('renders Welcome Back heading', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    //checking if subtitle appears
    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Sign in to access your digital pantry'), findsOneWidget);
    });

    //checking if email field appears
    testWidgets('renders email field', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Email Address'), findsOneWidget);
    });

    //checking if password label appears
    testWidgets('renders password label', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Password'), findsOneWidget);
    });

    //checking if forgot password button appears
    testWidgets('renders forgot password button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    //checking if login button appears
    testWidgets('renders login button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Log In'), findsOneWidget);
    });

    //checking if Google sign in button appears
    testWidgets('renders Google sign in button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    //checking if create account link appears
    testWidgets('renders create account link', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Create Account'), findsOneWidget);
    });

    //checking if login button shows loading state
    testWidgets('shows loading state when login button tapped', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.text('Log In'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2)); //wait for loading to finish
    });
  });
}