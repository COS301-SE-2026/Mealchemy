
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/vault/screens/vault_screen.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/repositories/mock_vault_repository.dart';
import 'package:mealchemy/features/vault/widgets/vault_stats_card.dart';
import 'package:mealchemy/features/vault/widgets/vault_folder_list.dart';
import 'package:mealchemy/features/vault/widgets/vault_quick_strip.dart';

void main() {
  Widget buildWidget() {
    return ProviderScope(
      overrides: [
        vaultRepositoryProvider.overrideWithValue(MockVaultRepository()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const VaultScreen(),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => const Scaffold(body: Text('Login')),
            ),
            GoRoute(
              path: '/pantry',
              builder: (context, state) => const Scaffold(body: Text('Pantry')),
            ),
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const Scaffold(body: Text('Dashboard')),
            ),
            GoRoute(
              path: '/recipe/add',
              builder: (context, state) => const Scaffold(body: Text('Add Recipe')),
            ),
          ],
        ),
      ),
    );
  }

  group('VaultScreen', () {
    //Building vault screen and checking it renders without crashing
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(VaultScreen), findsOneWidget);
    });

    //Building vault screen and checking MY VAULT label appears
    testWidgets('renders MY VAULT label', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('MY VAULT'), findsOneWidget);
    });

    //Building vault screen and checking FAB appears
    testWidgets('renders floating action button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    //Building vault screen and checking Vault title appears
    testWidgets('renders Vault title', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Vault'), findsOneWidget);
    });

    //Building vault screen and checking stats card appears
    testWidgets('renders stats card', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(VaultStatsCard), findsOneWidget);
    });

    //Building vault screen and checking folder list appears
    testWidgets('renders folder list', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(VaultFolderList), findsOneWidget);
    });

    //Building vault screen and checking quick strip appears
    testWidgets('renders quick strip', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(VaultQuickStrip), findsOneWidget);
    });
  });
}