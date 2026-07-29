import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/widgets/vault_hero.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host({
    VoidCallback? onSearch,
    VoidCallback? onAdd,
    VoidCallback? onShoppingList,
    List<Override> extraOverrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        isSharedModeProvider.overrideWith((ref) => false),
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: VaultHero(
            onSearch: onSearch ?? () {},
            onAdd: onAdd ?? () {},
            onShoppingList: onShoppingList ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders the Vault title', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('Vault'), findsOneWidget);
  });

  testWidgets('renders the search, add and shopping-list icons',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
  });

  testWidgets('tapping search fires onSearch', (tester) async {
    var tapped = false;
    await tester.pumpWidget(host(onSearch: () => tapped = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    expect(tapped, isTrue);
  });

  testWidgets('tapping add fires onAdd', (tester) async {
    var tapped = false;
    await tester.pumpWidget(host(onAdd: () => tapped = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    expect(tapped, isTrue);
  });

  testWidgets('tapping the shopping-list icon fires onShoppingList',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(host(onShoppingList: () => tapped = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    expect(tapped, isTrue);
  });
}