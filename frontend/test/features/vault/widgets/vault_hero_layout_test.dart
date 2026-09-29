import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/widgets/shared_vault_strip.dart';
import 'package:mealchemy/features/vault/widgets/vault_hero.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'shared vaults use the full header width and the last vault is selectable',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final vaults = List.generate(
        6,
        (index) => Vault(
          vaultId: index + 1,
          vaultType: VaultTypes.shared,
          name: 'Vault ${index + 1}',
          createdAt: DateTime.utc(2026, 9, 28),
        ),
      );

      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isSharedModeProvider.overrideWith((ref) => true),
            vaultsProvider.overrideWith((ref) async => vaults),
            sharedVaultsProvider.overrideWithValue(vaults),
            selectedVaultIdProvider.overrideWith((ref) => 1),
            selectedVaultProvider.overrideWith((ref) {
              final id = ref.watch(selectedVaultIdProvider);
              return vaults.firstWhere(
                (vault) => vault.vaultId == id,
                orElse: () => vaults.first,
              );
            }),
            shoppingListCountProvider.overrideWith((ref) => 0),
            vaultSessionProvider.overrideWithValue((
              userId: null,
              token: null,
              restoring: false,
              hasValidCredential: false,
            )),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Consumer(
              builder: (context, ref, child) {
                container = ProviderScope.containerOf(context);

                return const Scaffold(
                  body: SingleChildScrollView(
                    child: VaultHero(),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 360px screen minus the header's 20px padding on each side.
      expect(
        tester.getSize(find.byType(SharedVaultStrip)).width,
        closeTo(320, 0.01),
      );

      final stripList = find.descendant(
        of: find.byType(SharedVaultStrip),
        matching: find.byType(ListView),
      );

      await tester.drag(stripList, const Offset(-800, 0));
      await tester.pumpAndSettle();

      expect(find.text('Vault 6').hitTestable(), findsOneWidget);

      await tester.tap(find.text('Vault 6').hitTestable());
      await tester.pumpAndSettle();

      expect(container.read(selectedVaultIdProvider), 6);
      expect(
        tester.widget<Text>(find.text('Vault 6')).style?.fontWeight,
        FontWeight.w700,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
