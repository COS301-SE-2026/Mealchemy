import 'dart:async';

import 'package:mealchemy/core/providers/api_service_provider.dart';
import 'package:mealchemy/core/services/auth_interceptor.dart';
import 'package:mealchemy/features/auth/models/auth_result.dart';
import 'package:mealchemy/features/auth/models/user.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/auth/repositories/auth_repository.dart';
import 'package:mealchemy/features/auth/storage/auth_session_storage.dart';
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
      expect(
          find.text('Sign in to access your digital pantry'), findsOneWidget);
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

    //checking if login button appears
    testWidgets('renders login button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Log In'), findsOneWidget);
    });

    //checking the removed sign in options are gone
    testWidgets('does not render Google sign in or forgot password',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Sign in with Google'), findsNothing);
      expect(find.text('Forgot Password?'), findsNothing);
      expect(find.text('OR CONTINUE WITH'), findsNothing);
    });

    //checking if create account link appears
    testWidgets('renders create account link', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Create Account'), findsOneWidget);
    });

    //checking if login button shows loading state
    testWidgets('shows loading state when login button tapped', (tester) async {
      final repository = _PendingAuthRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          authSessionStorageProvider.overrideWithValue(
            _EmptyAuthSessionStorage(),
          ),
          authInterceptorProvider.overrideWithValue(AuthInterceptor()),
        ],
      );

      try {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: const Scaffold(
                body: SingleChildScrollView(child: LoginForm()),
              ),
            ),
          ),
        );

        // Finish restoring the empty test session before submitting.
        container.read(authProvider);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).at(0),
          'chef@mealchemy.com',
        );
        await tester.enterText(
          find.byType(TextField).at(1),
          'Password123!',
        );
        await tester.tap(find.text('Log In'));
        await tester.pump();

        expect(repository.loginCalls, 1);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the request explicitly so the spinner can stop.
        repository.response.complete(
          AuthResult.failure('Invalid email or password'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Invalid email or password'), findsOneWidget);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.pump(Duration.zero);
      }
    });
  });
}

class _PendingAuthRepository implements AuthRepository {
  final response = Completer<AuthResult>();
  int loginCalls = 0;

  @override
  Future<AuthResult> login(String email, String password) {
    loginCalls++;
    return response.future;
  }

  @override
  Future<AuthResult> register(
    String email,
    String password,
    String displayName,
  ) async {
    return AuthResult.failure('Registration is not used in this test.');
  }

  @override
  Future<void> logout() async {}
}

class _EmptyAuthSessionStorage implements AuthSessionStorage {
  @override
  Future<User?> readIdentity() async => null;

  @override
  Future<String?> readToken() async => null;

  @override
  Future<void> writeIdentity(User user) async {}

  @override
  Future<void> writeToken(String token) async {}

  @override
  Future<void> clearIdentity() async {}

  @override
  Future<void> clearToken() async {}
}
