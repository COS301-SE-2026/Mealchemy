import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/widgets/vault_switcher.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final vaults = [
    Vault(
      vaultId: 1,
      vaultType: VaultTypes.private,
      name: 'My Vault',
      createdAt: DateTime(2026, 1, 1),
    ),
  ];


  Widget host({
    required bool sharedMode,
    Future<List<Vault>>? vaultsFuture,
  }) {
    return ProviderScope(
      overrides: [
        vaultsProvider.overrideWith(
          (ref) => vaultsFuture ?? Future.value(vaults),
        ),
        isSharedModeProvider.overrideWith((ref) => sharedMode),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: VaultSwitcher()),
      ),
    );
  }

  testWidgets('renders nothing until vaults have loaded', (tester) async {
    final pending = Completer<List<Vault>>();
    await tester.pumpWidget(host(sharedMode: false, vaultsFuture: pending.future));
    await tester.pump();

    // Still loading valueOrNull is null, so the switcher collapses.
    expect(find.text('Private Vault'), findsNothing);

    pending.complete(vaults);
    await tester.pumpAndSettle();
  });

  testWidgets('shows the private label and lock icon in private mode',
      (tester) async {
    await tester.pumpWidget(host(sharedMode: false));
    await tester.pumpAndSettle();

    expect(find.text('Private Vault'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('shows the shared label and group icon in shared mode',
      (tester) async {
    await tester.pumpWidget(host(sharedMode: true));
    await tester.pumpAndSettle();

    expect(find.text('Shared Vaults'), findsOneWidget);
    expect(find.byIcon(Icons.group_outlined), findsOneWidget);
  });

  testWidgets('selecting "Shared Vaults" switches the mode to shared',
      (tester) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vaultsProvider.overrideWith((ref) => Future.value(vaults)),
          isSharedModeProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return Scaffold(body: const VaultSwitcher());
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open the popup 
    await tester.tap(find.text('Private Vault'));
    await tester.pumpAndSettle();

    // Tap the "Shared Vaults" menu item the label now appears in the popup.
    await tester.tap(find.text('Shared Vaults').last);
    await tester.pumpAndSettle();

    expect(container.read(isSharedModeProvider), isTrue);
    expect(container.read(selectedVaultIdProvider), isNull);
  });
}