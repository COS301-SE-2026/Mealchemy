import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/ingredients/models/ingredient_catalogue_item.dart';
import 'package:mealchemy/features/recipe/models/unit_of_measurement.dart';
import 'package:mealchemy/features/recipe/widgets/ingredient_editor_row.dart';
import 'package:mealchemy/features/ingredients/models/ingredient_category.dart';
import 'package:mealchemy/features/ingredients/providers/ingredient_catalogue_provider.dart';
import 'package:mealchemy/features/ingredients/repositories/ingredient_catalogue_repository.dart';
import 'package:mealchemy/features/ingredients/models/pending_external_ingredient.dart';

class _ExternalCatalogueRepository implements IngredientCatalogueRepository {
  _ExternalCatalogueRepository({
    this.requiresCategory = false,
    this.shouldFailCategoryLoad = false,
  });

  final bool requiresCategory;
  final bool shouldFailCategoryLoad;
  String? lastImportedSourceId;
  int? lastImportedCategoryId;
  final List<int?> importedCategoryIds = [];
  int categoryRequestCount = 0;

  @override
  Future<List<IngredientCatalogueItem>> getAll() async => const [];

  @override
  Future<List<IngredientCatalogueItem>> search(String query) async {
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
  Future<List<IngredientCategory>> getCategories() async {
    categoryRequestCount++;

    if (shouldFailCategoryLoad) {
      throw Exception('Could not load categories.');
    }

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
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const units = [
    UnitOfMeasurement(unitId: 1, name: 'g', system: 'METRIC'),
    UnitOfMeasurement(unitId: 2, name: 'tbsp', system: null),
  ];

  const chicken =
      IngredientCatalogueItem(ingId: 7, name: 'Chicken', category: 'Meat');

  Future<void> pumpRow(
    WidgetTester tester, {
    IngredientCatalogueItem? selectedItem,
    TextEditingController? quantityController,
    String? selectedUnit,
    ValueChanged<String?>? onUnitChanged,
    ValueChanged<IngredientCatalogueItem>? onItemSelected,
    IngredientCatalogueRepository? catalogueRepository,
    VoidCallback? onRemove,
    bool showError = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (catalogueRepository != null)
            ingredientCatalogueRepositoryProvider.overrideWithValue(
              catalogueRepository,
            ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: IngredientEditorRow(
              selectedItem: selectedItem,
              quantityController: quantityController ?? TextEditingController(),
              units: units,
              selectedUnit: selectedUnit,
              onUnitChanged: onUnitChanged ?? (_) {},
              onItemSelected: onItemSelected ?? (_) {},
              onRemove: onRemove ?? () {},
              showError: showError,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the search placeholder when no ingredient is selected',
      (tester) async {
    await pumpRow(tester);
    expect(find.text('Search ingredient'), findsOneWidget);
  });

  testWidgets('shows the selected ingredient name, bound to the model',
      (tester) async {
    await pumpRow(tester, selectedItem: chicken);
    expect(find.text('Chicken'), findsOneWidget);
    expect(find.text('Search ingredient'), findsNothing);
  });

  testWidgets('unit dropdown lists the provided units and reports selection',
      (tester) async {
    String? changedTo;
    await pumpRow(tester, onUnitChanged: (v) => changedTo = v);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('g'), findsWidgets);
    expect(find.text('tbsp'), findsWidgets);

    await tester.tap(find.text('tbsp').last);
    await tester.pumpAndSettle();
    expect(changedTo, 'tbsp');
  });

  testWidgets('preselected unit is reflected in the dropdown', (tester) async {
    await pumpRow(tester, selectedUnit: 'g');
    expect(find.text('g'), findsWidgets);
  });

  testWidgets('typing routes through the quantity controller', (tester) async {
    final qty = TextEditingController();
    await pumpRow(tester, quantityController: qty);

    await tester.enterText(find.widgetWithText(TextField, 'Qty'), '250');
    expect(qty.text, '250');
  });

  testWidgets('quantity controller initial value is shown in the field',
      (tester) async {
    final qty = TextEditingController(text: '125');

    await pumpRow(tester, quantityController: qty);

    expect(find.widgetWithText(TextField, '125'), findsOneWidget);
  });

  testWidgets('tapping remove fires onRemove', (tester) async {
    var removed = false;
    await pumpRow(tester, onRemove: () => removed = true);

    await tester.tap(find.byTooltip('Remove'));
    expect(removed, isTrue);
  });

  testWidgets('error text is shown only when showError is true',
      (tester) async {
    const message = 'Pick an ingredient and enter quantity + unit.';

    await pumpRow(tester, showError: false);
    expect(find.text(message), findsNothing);

    await pumpRow(tester, showError: true);
    expect(find.text(message), findsOneWidget);
  });

  testWidgets('renders the search field icon and remove button',
      (tester) async {
    await pumpRow(tester);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('imports USDA result before selecting recipe ingredient', (
    tester,
  ) async {
    final repository = _ExternalCatalogueRepository();
    IngredientCatalogueItem? selectedIngredient;

    await pumpRow(
      tester,
      catalogueRepository: repository,
      onItemSelected: (item) => selectedIngredient = item,
    );

    await tester.tap(find.text('Search ingredient'));
    await tester.pumpAndSettle();

    final catalogueSearchField = find.widgetWithText(
      TextField,
      'e.g. chicken',
    );

    expect(catalogueSearchField, findsOneWidget);

    await tester.enterText(
      catalogueSearchField,
      'kimchi',
    );
    await tester.pumpAndSettle();

    expect(find.text('Kimchi'), findsOneWidget);
    expect(find.text('USDA result'), findsOneWidget);

    await tester.tap(find.text('Kimchi'));
    await tester.pumpAndSettle();

    expect(repository.lastImportedSourceId, '2710077');
    expect(repository.lastImportedCategoryId, isNull);
    expect(selectedIngredient?.ingId, 25);
    expect(selectedIngredient?.name, 'Kimchi');
  });

  testWidgets('chooses category and retries USDA recipe ingredient import', (
    tester,
  ) async {
    final repository = _ExternalCatalogueRepository(
      requiresCategory: true,
    );
    IngredientCatalogueItem? selectedIngredient;

    await pumpRow(
      tester,
      catalogueRepository: repository,
      onItemSelected: (item) => selectedIngredient = item,
    );

    await tester.tap(find.text('Search ingredient'));
    await tester.pumpAndSettle();

    final catalogueSearchField = find.widgetWithText(
      TextField,
      'e.g. chicken',
    );

    await tester.enterText(catalogueSearchField, 'kimchi');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kimchi'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a category'), findsOneWidget);
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(repository.categoryRequestCount, 1);

    final categoryDialog = find.widgetWithText(
      AlertDialog,
      'Choose a category',
    );

    final dairyOption = find.descendant(
      of: categoryDialog,
      matching: find.text('Dairy'),
    );

    expect(dairyOption, findsOneWidget);

    await tester.tap(dairyOption);
    await tester.pumpAndSettle();

    expect(repository.importedCategoryIds, [null, 4]);
    expect(selectedIngredient?.ingId, 25);
    expect(selectedIngredient?.name, 'Kimchi');
    expect(selectedIngredient?.category, 'Dairy');
    expect(find.text('Choose a category'), findsNothing);
  });

  testWidgets(
    'cancels recipe category selection without retrying import',
    (tester) async {
      final repository = _ExternalCatalogueRepository(
        requiresCategory: true,
      );
      IngredientCatalogueItem? selectedIngredient;

      await pumpRow(
        tester,
        catalogueRepository: repository,
        onItemSelected: (item) => selectedIngredient = item,
      );

      await tester.tap(find.text('Search ingredient'));
      await tester.pumpAndSettle();

      final catalogueSearchField = find.widgetWithText(
        TextField,
        'e.g. chicken',
      );

      await tester.enterText(catalogueSearchField, 'kimchi');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kimchi'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a category'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      //only first request with category_id null was made
      expect(repository.importedCategoryIds, [null]);
      expect(selectedIngredient, isNull);
      expect(find.text('Choose a category'), findsNothing);
      expect(find.text('Kimchi'), findsOneWidget);
    },
  );

  testWidgets(
    'shows error when recipe ingredient categories cannot be loaded',
    (tester) async {
      final repository = _ExternalCatalogueRepository(
        requiresCategory: true,
        shouldFailCategoryLoad: true,
      );
      IngredientCatalogueItem? selectedIngredient;

      await pumpRow(
        tester,
        catalogueRepository: repository,
        onItemSelected: (item) => selectedIngredient = item,
      );

      await tester.tap(find.text('Search ingredient'));
      await tester.pumpAndSettle();

      final catalogueSearchField = find.widgetWithText(
        TextField,
        'e.g. chicken',
      );

      await tester.enterText(catalogueSearchField, 'kimchi');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kimchi'));
      await tester.pumpAndSettle();

      expect(repository.categoryRequestCount, 1);
      expect(repository.importedCategoryIds, [null]);
      expect(selectedIngredient, isNull);
      expect(find.text('Choose a category'), findsNothing);
      expect(
        find.text('Could not import Kimchi. Try again.'),
        findsOneWidget,
      );
    },
  );
}
