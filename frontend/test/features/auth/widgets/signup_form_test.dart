import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/auth/widgets/signup_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
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
                body: SingleChildScrollView(child: SignupForm()),
              ),
            ),
            GoRoute(
              path: '/preference',
              builder: (context, state) => const Scaffold(
                body: Text('Preference'),
              ),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => const Scaffold(
                body: Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  group('SignupForm', () {
    //Building signup form
    //checking if Create Account heading appears
    testWidgets('renders Create Account heading', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Create Account'), findsWidgets);
    });

    //checking if subtitle appears
    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Join Mealchemy and start your culinary journey'), findsOneWidget);
    });

    //checking  if display name field appears
    testWidgets('renders display name field', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Display Name'), findsOneWidget);
    });

    //checking if email field appear
    testWidgets('renders email field', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Email Address'), findsOneWidget);
    });

    //checking if password label appears
    testWidgets('renders password label', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Password'), findsOneWidget);
    });

    //checking if confirm  password label appears
    testWidgets('renders confirm password label', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    //checking if Google  sign up button appears
    testWidgets('renders Google sign up button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Sign up with Google'), findsOneWidget);
    });

    //checking if sign in link appears
    testWidgets('renders sign in link', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Sign In'), findsOneWidget);
    });

    //checking if register  button shows loading state
    // //TODO: fix test - navigation to /preference causes test environment to fail
    // testWidgets('shows loading state when register button tapped', (tester) async {
    //   await tester.pumpWidget(buildWidget());
    //   await tester.tap(find.text('Create Account').first);
    //   await tester.pump();
    //   expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //   await tester.pumpAndSettle(const Duration(seconds: 4)); 
    // });
  });
}