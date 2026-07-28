import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/widgets/shared_vault_strip.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Vault vault(int id, String name) => Vault(
        vaultId: id,
        vaultType: VaultTypes.shared,
        name: name,
        createdAt: DateTime(2026, 1, 1),
      );

  final teamA = vault(1, 'Alpha');
  final teamB = vault(2, 'Bravo');

  Widget host({
    required bool sharedMode,
    List<Vault> shared = const [],
    Vault? selected,
    int? selectedId,
  }) {
    return ProviderScope(
      overrides: [
        isSharedModeProvider.overrideWith((ref) => sharedMode),
        sharedVaultsProvider.overrideWithValue(shared),
        selectedVaultProvider.overrideWithValue(selected),
        if (selectedId != null)
          selectedVaultIdProvider.overrideWith((ref) => selectedId),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SharedVaultStrip()),
      ),
    );
  }

  testWidgets('renders nothing when not in shared mode', (tester) async {
    await tester.pumpWidget(host(sharedMode: false, shared: [teamA]));
    await tester.pumpAndSettle();

    expect(find.text('Add Vault'), findsNothing);
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('in shared mode shows the Add Vault circle and each vault',
      (tester) async {
    await tester.pumpWidget(host(
      sharedMode: true,
      shared: [teamA, teamB],
      selected: teamA,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Add Vault'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Bravo'), findsOneWidget);
    // Avatar initials.
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('highlights the selected vault label', (tester) async {
    await tester.pumpWidget(host(
      sharedMode: true,
      shared: [teamA, teamB],
      selected: teamB,
    ));
    await tester.pumpAndSettle();

    final selectedLabel = tester.widget<Text>(find.text('Bravo'));
    expect(selectedLabel.style?.fontWeight, FontWeight.w700);

    final unselectedLabel = tester.widget<Text>(find.text('Alpha'));
    expect(unselectedLabel.style?.fontWeight, FontWeight.w400);
  });

  testWidgets('tapping a vault sets it as the selected vault id',
      (tester) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSharedModeProvider.overrideWith((ref) => true),
          sharedVaultsProvider.overrideWithValue([teamA, teamB]),
          selectedVaultProvider.overrideWithValue(teamA),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return const Scaffold(body: SharedVaultStrip());
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bravo'));
    await tester.pumpAndSettle();

    expect(container.read(selectedVaultIdProvider), 2);
  });
}