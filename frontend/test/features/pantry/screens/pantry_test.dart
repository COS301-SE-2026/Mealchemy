import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/pantry/models/pantry_ingredient.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';
import 'package:mealchemy/features/pantry/repositories/mock_pantry_repository.dart';
import 'package:mealchemy/features/pantry/screens/pantry_screen.dart';
import 'package:mealchemy/features/pantry/widgets/pantry_item_card.dart';
import 'package:mealchemy/features/pantry/models/pantry_summary.dart';

class _EditingPantryRepository extends MockPantryRepository {
  @override
  Future<PantryIngredient> updatePantryIngredient({
    required int pIngredientId,
    required int ingId,
    required String quantity,
    required String unit,
  }) async {
    return PantryIngredient(
      pIngredientId: pIngredientId,
      ingId: ingId,
      name: 'Chicken Breast',
      details: '$quantity$unit • Pantry',
      category: 'Proteins',
      status: PantryItemStatus.fresh,
      quantity: quantity,
      unit: unit,
    );
  }
}

class _FailingEditPantryRepository extends MockPantryRepository {
  @override
  Future<PantryIngredient> updatePantryIngredient({
    required int pIngredientId,
    required int ingId,
    required String quantity,
    required String unit,
  }) {
    throw Exception('Update failed');
  }
}

class _EmptyPantryRepository extends MockPantryRepository {
  @override
  Future<List<PantryIngredient>> getPantryIngredients() async {
    return const [];
  }
}

class _DeletePantryRepository extends MockPantryRepository {
  @override
  Future<List<PantryIngredient>> getPantryIngredients() async {
    return const [
      PantryIngredient(
        pIngredientId: 50,
        ingId: 150,
        name: 'Expired Test Item',
        details: '1g • Expired',
        category: 'Test',
        status: PantryItemStatus.expired,
        quantity: '1',
        unit: 'g',
      ),
    ];
  }

  @override
  Future<List<PantryFilter>> getPantryFilters() async {
    return const [
      PantryFilter(label: 'All', count: 1),
      PantryFilter(label: 'Test', count: 1),
    ];
  }
}

void main() {
  setUpAll(() {
    //disable fonts during tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpPantryScreen(
    WidgetTester tester, {
    MockPantryRepository? pantryRepository,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(
            pantryRepository ?? MockPantryRepository(),
          ),
        ],
        child: const MaterialApp(
          home: PantryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  //make sure renders everything
  testWidgets('PantryScreen renders pantry overview', (tester) async {
    await pumpPantryScreen(tester);

    expect(find.text('Pantry'), findsWidgets);
    expect(find.text('Meal Optimization'), findsOneWidget);
    expect(find.text('Proteins'), findsOneWidget);
    expect(find.text('Chicken Breast'), findsOneWidget);
  });

  testWidgets('PantryScreen filters pantry items by search query',
      (tester) async {
    await pumpPantryScreen(tester);

    await tester.enterText(find.byType(TextField), 'milk');
    await tester.pumpAndSettle();

    expect(find.text('Full Cream Milk'), findsOneWidget);
    expect(find.text('Chicken Breast'), findsNothing);
  });

  testWidgets('PantryScreen filters pantry items by category', (tester) async {
    await pumpPantryScreen(tester);

    final dairyFilter = find.textContaining('Dairy').first;
    await tester.ensureVisible(dairyFilter);
    await tester.tap(dairyFilter);
    await tester.pumpAndSettle();

    expect(find.text('Full Cream Milk'), findsOneWidget);
    expect(find.text('Chicken Breast'), findsNothing);
  });

  testWidgets('PantryScreen edits pantry ingredient quantity and unit',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpPantryScreen(
      tester,
      pantryRepository: _EditingPantryRepository(),
    );

    final chickenCard = find.ancestor(
      of: find.text('Chicken Breast'),
      matching: find.byType(PantryItemCard),
    );

    final editIcon = find.descendant(
      of: chickenCard,
      matching: find.byIcon(Icons.edit_outlined),
    );

    await tester.ensureVisible(chickenCard);
    await tester.pumpAndSettle();

    await tester.tap(editIcon, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Edit Ingredient'), findsOneWidget);

    final quantityField = find.byType(TextField).last;
    await tester.enterText(quantityField, '2');
    await tester.pumpAndSettle();

    final unitDropdown = find.byType(DropdownButtonFormField<String>);
    await tester.tap(unitDropdown);
    await tester.pumpAndSettle();

    await tester.tap(find.text('kg').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Chicken Breast'), findsOneWidget);
    expect(find.text('2kg • Pantry'), findsOneWidget);
  });

  testWidgets('PantryScreen validates edit pantry ingredient form',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpPantryScreen(tester);

    final chickenCard = find.ancestor(
      of: find.text('Chicken Breast'),
      matching: find.byType(PantryItemCard),
    );

    final editIcon = find.descendant(
      of: chickenCard,
      matching: find.byIcon(Icons.edit_outlined),
    );

    await tester.ensureVisible(chickenCard);
    await tester.pumpAndSettle();

    await tester.tap(editIcon, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Edit Ingredient'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Quantity and unit are required.'), findsOneWidget);
  });

  testWidgets('PantryScreen shows error when editing pantry ingredient fails',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpPantryScreen(
      tester,
      pantryRepository: _FailingEditPantryRepository(),
    );

    final chickenCard = find.ancestor(
      of: find.text('Chicken Breast'),
      matching: find.byType(PantryItemCard),
    );

    final editIcon = find.descendant(
      of: chickenCard,
      matching: find.byIcon(Icons.edit_outlined),
    );

    await tester.ensureVisible(chickenCard);
    await tester.pumpAndSettle();

    await tester.tap(editIcon, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Edit Ingredient'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '2');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Could not update ingredient.'), findsOneWidget);
  });
  testWidgets('PantryScreen closes edit dialog when cancel is tapped',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpPantryScreen(tester);

    final chickenCard = find.ancestor(
      of: find.text('Chicken Breast'),
      matching: find.byType(PantryItemCard),
    );

    final editIcon = find.descendant(
      of: chickenCard,
      matching: find.byIcon(Icons.edit_outlined),
    );

    await tester.ensureVisible(chickenCard);
    await tester.pumpAndSettle();

    await tester.tap(editIcon, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Edit Ingredient'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Ingredient'), findsNothing);
  });

  testWidgets('PantryScreen shows empty pantry message', (tester) async {
    await pumpPantryScreen(
      tester,
      pantryRepository: _EmptyPantryRepository(),
    );

    expect(find.text('No pantry ingredients found.'), findsOneWidget);
  });

  testWidgets('PantryScreen shows empty search results message',
      (tester) async {
    await pumpPantryScreen(tester);

    await tester.enterText(find.byType(TextField), 'dragonfruit');
    await tester.pumpAndSettle();

    expect(find.text('No ingredients match "dragonfruit".'), findsOneWidget);
  });

  testWidgets('PantryScreen closes edit dialog when cancel is tapped',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpPantryScreen(tester);

    final chickenCard = find.ancestor(
      of: find.text('Chicken Breast'),
      matching: find.byType(PantryItemCard),
    );

    final editIcon = find.descendant(
      of: chickenCard,
      matching: find.byIcon(Icons.edit_outlined),
    );

    await tester.ensureVisible(chickenCard);
    await tester.pumpAndSettle();

    await tester.tap(editIcon, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Edit Ingredient'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Ingredient'), findsNothing);
  });

  testWidgets('PantryScreen removes expired pantry ingredient', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpPantryScreen(
      tester,
      pantryRepository: _DeletePantryRepository(),
    );

    expect(find.text('Expired Test Item'), findsOneWidget);

    final expiredCard = find.ancestor(
      of: find.text('Expired Test Item'),
      matching: find.byType(PantryItemCard),
    );

    final deleteIcon = find.descendant(
      of: expiredCard,
      matching: find.byIcon(Icons.delete_outline),
    );

    await tester.tap(deleteIcon, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Expired Test Item'), findsNothing);
  });

  testWidgets('PantryScreen shows empty pantry message', (tester) async {
    await pumpPantryScreen(
      tester,
      pantryRepository: _EmptyPantryRepository(),
    );

    expect(find.text('No pantry ingredients found.'), findsOneWidget);
  });

  testWidgets('PantryScreen shows empty search results message',
      (tester) async {
    await pumpPantryScreen(tester);

    await tester.enterText(find.byType(TextField), 'dragonfruit');
    await tester.pumpAndSettle();

    expect(find.text('No ingredients match "dragonfruit".'), findsOneWidget);
  });
}
