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
import 'package:dio/dio.dart';
import 'package:mealchemy/features/pantry/models/ingredient_catalogue_item.dart';
import 'package:mealchemy/features/pantry/repositories/ingredient_catalogue_repository.dart';
import 'package:mealchemy/features/pantry/models/ingredient_category.dart';
import 'package:mealchemy/features/pantry/models/pending_external_ingredient.dart';

class _ExternalIngredientCatalogueRepository
    extends IngredientCatalogueRepository {
  _ExternalIngredientCatalogueRepository({
    this.requiresCategory = false,
  }) : super(Dio());

  final bool requiresCategory;

  String? lastImportedSourceId;
  int? lastImportedCategoryId;
  final List<int?> importedCategoryIds = [];
  int categoryRequestCount = 0;

  @override
  Future<List<IngredientCatalogueItem>> searchIngredients(String query) async {
    return const [
      IngredientCatalogueItem(
        ingId: null,
        name: 'Kimchi',
        category: null,
        sourceId: '2710077',
        sourceApi: 'USDA',
      ),
    ];
  }

  @override
  Future<IngredientCatalogueItem> importExternalIngredient({
    required String sourceId,
    int? categoryId,
  }) async {
    lastImportedSourceId = sourceId;
    lastImportedCategoryId = categoryId;
    importedCategoryIds.add(categoryId);

    if (requiresCategory && categoryId == null) {
      throw const ExternalIngredientCategoryRequiredException(
        PendingExternalIngredient(
          sourceId: '2710077',
          name: 'Kimchi',
        ),
      );
    }

    return IngredientCatalogueItem(
      ingId: 25,
      name: 'Kimchi',
      category: categoryId == null ? 'Vegetables' : 'Dairy',
    );
  }

  @override
  Future<List<IngredientCategory>> getCategories() async {
    categoryRequestCount++;

    return const [
      IngredientCategory(
        categoryId: 1,
        name: 'Baked Products',
      ),
      IngredientCategory(
        categoryId: 4,
        name: 'Dairy',
      ),
    ];
  }
}

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
    IngredientCatalogueRepository? catalogueRepository,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(
            pantryRepository ?? MockPantryRepository(),
          ),
          if (catalogueRepository != null)
            ingredientCatalogueRepositoryProvider.overrideWithValue(
              catalogueRepository,
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

  testWidgets('PantryScreen clears ingredient search when edit name is empty',
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

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    expect(find.text('Edit Ingredient'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Could not search ingredients.'), findsNothing);
  });

  testWidgets('PantryScreen shows ingredient search error in edit dialog',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(MockPantryRepository()),
          ingredientCatalogueRepositoryProvider.overrideWith(
            (ref) => throw Exception('Search failed'),
          ),
        ],
        child: const MaterialApp(
          home: PantryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

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

    await tester.enterText(find.byType(TextField).first, 'yogurt');
    await tester.pumpAndSettle();

    expect(find.text('Could not search ingredients.'), findsOneWidget);
  });

  testWidgets('PantryScreen deletes pantry ingredient from card',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpPantryScreen(tester);

    final chickenCard = find.ancestor(
      of: find.text('Chicken Breast'),
      matching: find.byType(PantryItemCard),
    );

    final deleteIcon = find.descendant(
      of: chickenCard,
      matching: find.byIcon(Icons.delete_outline),
    );

    await tester.ensureVisible(chickenCard);
    await tester.pumpAndSettle();

    await tester.tap(deleteIcon, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Chicken Breast'), findsNothing);
  });

  testWidgets('PantryScreen imports USDA result in edit dialog', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final catalogueRepository = _ExternalIngredientCatalogueRepository();

    await pumpPantryScreen(
      tester,
      catalogueRepository: catalogueRepository,
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

    await tester.enterText(find.byType(TextField).first, 'kimchi');
    await tester.pumpAndSettle();

    expect(find.text('Kimchi'), findsOneWidget);
    expect(find.text('USDA result'), findsOneWidget);

    await tester.tap(find.text('Kimchi'));
    await tester.pumpAndSettle();

    expect(catalogueRepository.lastImportedSourceId, '2710077');
    expect(catalogueRepository.lastImportedCategoryId, isNull);
    expect(find.text('Could not import this ingredient.'), findsNothing);
  });

  testWidgets(
    'PantryScreen chooses category and retries USDA import in edit dialog',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final catalogueRepository = _ExternalIngredientCatalogueRepository(
        requiresCategory: true,
      );

      await pumpPantryScreen(
        tester,
        catalogueRepository: catalogueRepository,
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

      await tester.enterText(
        find.byType(TextField).first,
        'kimchi',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kimchi'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a category'), findsOneWidget);

      final categoryDialog = find.widgetWithText(
        AlertDialog,
        'Choose a category',
      );

      final bakedProductsOption = find.descendant(
        of: categoryDialog,
        matching: find.text('Baked Products'),
      );

      final dairyOption = find.descendant(
        of: categoryDialog,
        matching: find.text('Dairy'),
      );

      expect(bakedProductsOption, findsOneWidget);
      expect(dairyOption, findsOneWidget);
      expect(catalogueRepository.categoryRequestCount, 1);

      await tester.tap(dairyOption);
      await tester.pumpAndSettle();

      expect(
        catalogueRepository.importedCategoryIds,
        [null, 4],
      );
      expect(find.text('Choose a category'), findsNothing);
      expect(
        catalogueRepository.lastImportedCategoryId,
        4,
      );
    },
  );
}
