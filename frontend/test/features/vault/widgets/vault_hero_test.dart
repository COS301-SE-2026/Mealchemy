import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/widgets/vault_hero.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  // Records the last route pushed so we can assert the cart navigates.
  late String? pushedRoute;

  Widget host({
    int cartCount = 0,
    List<Override> extraOverrides = const [],
  }) {
    pushedRoute = null;

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: VaultHero()),
        ),
        GoRoute(
          path: AppRoutes.shoppingLists,
          builder: (context, state) {
            pushedRoute = AppRoutes.shoppingLists;
            return const Scaffold(body: SizedBox());
          },
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        isSharedModeProvider.overrideWith((ref) => false),
        shoppingListCountProvider.overrideWith((ref) => cartCount),
        ...extraOverrides,
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  testWidgets('renders the Vault title', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('Vault'), findsOneWidget);
  });

  testWidgets('renders the cart icon', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
  });

  testWidgets('shows the count badge when there are lists', (tester) async {
    await tester.pumpWidget(host(cartCount: 3));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('hides the badge when the count is zero', (tester) async {
    await tester.pumpWidget(host(cartCount: 0));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsNothing);
  });

  testWidgets('tapping the cart navigates to the shopping lists',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();

    expect(pushedRoute, AppRoutes.shoppingLists);
  });
}