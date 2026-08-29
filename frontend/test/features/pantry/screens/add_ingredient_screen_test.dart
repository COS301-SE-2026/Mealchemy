import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/pantry/models/ingredient_catalogue_item.dart';
import 'package:mealchemy/features/pantry/models/pantry_ingredient.dart';
import 'package:mealchemy/features/pantry/models/pantry_summary.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';
import 'package:mealchemy/features/pantry/repositories/ingredient_catalogue_repository.dart';
import 'package:mealchemy/features/pantry/repositories/pantry_repository.dart';
import 'package:mealchemy/features/pantry/screens/add_ingredient_screen.dart';
import 'package:mealchemy/features/pantry/widgets/pantry_item_card.dart';
import 'package:mealchemy/features/pantry/models/ingredient_category.dart';
import 'package:mealchemy/features/pantry/models/pending_external_ingredient.dart';

class _FakeIngredientCatalogueRepository extends IngredientCatalogueRepository {
  _FakeIngredientCatalogueRepository({
    this.requiresCategory = false,
    this.shouldFailCategoryLoad = false,
  }) : super(Dio());

  final bool requiresCategory;
  final bool shouldFailCategoryLoad;

  String? lastSearchQuery;
  String? lastImportedSourceId;
  int? lastImportedCategoryId;
  final List<int?> importedCategoryIds = [];
  int categoryRequestCount = 0;

  @override
  Future<List<IngredientCatalogueItem>> searchIngredients(String query) async {
    lastSearchQuery = query;

    if (query.toLowerCase().contains('kimchi')) {
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

    return const [
      IngredientCatalogueItem(
        ingId: 12,
        name: 'Milk',
        category: 'Dairy',
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

    //pretend backend imported USDA item into local catalogue
    return IngredientCatalogueItem(
      ingId: 25,
      name: 'Kimchi',
      category: categoryId == null ? 'Vegetables' : 'Dairy',
    );
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
}

class _RecordingPantryRepository implements PantryRepository {
  int? addedIngId;
  String? addedQuantity;
  String? addedUnit;

  @override
  Future<PantryIngredient> addPantryIngredient({
    required int ingId,
    required String quantity,
    required String unit,
  }) async {
    addedIngId = ingId;
    addedQuantity = quantity;
    addedUnit = unit;

    //pretend the backend created the pantry item successfully
    return PantryIngredient(
      pIngredientId: 99,
      ingId: ingId,
      name: 'Milk',
      details: '$quantity$unit • Pantry',
      category: 'Dairy',
      status: PantryItemStatus.fresh,
      quantity: quantity,
      unit: unit,
    );
  }

  @override
  Future<List<String>> getIngredientCategories() async {
    return const ['Dairy'];
  }

  @override
  Future<List<PantryFilter>> getPantryFilters() async {
    return const [PantryFilter(label: 'All', count: 0)];
  }

  @override
  Future<List<PantryIngredient>> getPantryIngredients() async {
    return const [];
  }

  @override
  Future<PantrySummary> getPantrySummary() async {
    return const PantrySummary(
      totalItems: 0,
      freshnessPercent: 100,
      categoryCount: 0,
      optimizationPercent: 72,
    );
  }

  @override
  Future<void> deletePantryIngredient(int pIngredientId) async {
    //not used in this screen test
  }

  @override
  Future<PantryIngredient> updatePantryIngredient({
    required int pIngredientId,
    required int ingId,
    required String quantity,
    required String unit,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<_RecordingPantryRepository> pumpAddIngredientScreen(
    WidgetTester tester, {
    _FakeIngredientCatalogueRepository? ingredientRepository,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final pantryRepository = _RecordingPantryRepository();

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: '/add',
          builder: (context, state) => const AddIngredientScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(pantryRepository),
          if (ingredientRepository != null)
            ingredientCatalogueRepositoryProvider
                .overrideWithValue(ingredientRepository),
        ],
        child: MaterialApp.router(
          theme: ThemeData(
            //keeps widget tests away from the problematic ink sparkle shader
            splashFactory: NoSplash.splashFactory,
          ),
          routerConfig: router,
        ),
      ),
    );

    router.push('/add');

    //waits for provider data to load
    await tester.pumpAndSettle();

    return pantryRepository;
  }

  testWidgets('AddIngredientScreen renders sheet title and form fields', (
    tester,
  ) async {
    await pumpAddIngredientScreen(tester);

    expect(find.text('Pantry Entry'), findsOneWidget);
    expect(find.text('Add Ingredient Manually'), findsOneWidget);
    expect(find.text('Ingredient Details'), findsOneWidget);
    expect(find.text('Ingredient Name'), findsOneWidget);
    expect(find.text('Unit'), findsOneWidget);
    expect(find.text('Save Ingredient'), findsOneWidget);
  });

  testWidgets('AddIngredientScreen validates required fields on save', (
    tester,
  ) async {
    await pumpAddIngredientScreen(tester);

    await tester.tap(find.text('Save Ingredient'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ingredient name is required.', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Please select an ingredient from the catalogue.',
          skipOffstage: false),
      findsNothing,
    );
    expect(
      find.text('Unit is required.', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('AddIngredientScreen quantity stepper increments and floors at 1',
      (
    tester,
  ) async {
    await pumpAddIngredientScreen(tester);

    //starts at 1 and the minus button does nothing at the floor
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    //last Icons.add is the stepper plus because the header also has add icon
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('AddIngredientScreen selects a unit from the dropdown', (
    tester,
  ) async {
    await pumpAddIngredientScreen(tester);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('g').last);
    await tester.pumpAndSettle();

    expect(find.text('g'), findsOneWidget);
  });

  testWidgets('AddIngredientScreen searches catalogue and selects ingredient', (
    tester,
  ) async {
    final ingredientRepository = _FakeIngredientCatalogueRepository();

    await pumpAddIngredientScreen(
      tester,
      ingredientRepository: ingredientRepository,
    );

    await tester.enterText(find.byType(TextField).first, 'milk');
    await tester.pumpAndSettle();

    expect(ingredientRepository.lastSearchQuery, 'milk');
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Dairy'), findsWidgets);

    await tester.tap(find.text('Milk'));
    await tester.pumpAndSettle();

    expect(find.text('Category: Dairy'), findsOneWidget);
  });

  testWidgets('AddIngredientScreen imports and selects USDA result', (
    tester,
  ) async {
    final ingredientRepository = _FakeIngredientCatalogueRepository();

    await pumpAddIngredientScreen(
      tester,
      ingredientRepository: ingredientRepository,
    );

    await tester.enterText(find.byType(TextField).first, 'kimchi');
    await tester.pumpAndSettle();

    expect(find.text('Kimchi'), findsOneWidget);
    expect(find.text('USDA result'), findsOneWidget);

    await tester.tap(find.text('Kimchi'));
    await tester.pumpAndSettle();

    expect(ingredientRepository.lastImportedSourceId, '2710077');
    expect(ingredientRepository.lastImportedCategoryId, isNull);
    expect(find.text('Category: Vegetables'), findsOneWidget);
  });

  testWidgets(
    'AddIngredientScreen chooses category and retries USDA import',
    (tester) async {
      final ingredientRepository = _FakeIngredientCatalogueRepository(
        requiresCategory: true,
      );

      await pumpAddIngredientScreen(
        tester,
        ingredientRepository: ingredientRepository,
      );

      await tester.enterText(find.byType(TextField).first, 'kimchi');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kimchi'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a category'), findsOneWidget);
      expect(find.text('Baked Products'), findsOneWidget);
      expect(find.text('Dairy'), findsOneWidget);
      expect(ingredientRepository.categoryRequestCount, 1);

      await tester.tap(find.text('Dairy').last);
      await tester.pumpAndSettle();

      expect(ingredientRepository.importedCategoryIds, [null, 4]);
      expect(find.text('Choose a category'), findsNothing);
      expect(find.text('Category: Dairy'), findsOneWidget);
    },
  );

  testWidgets(
    'AddIngredientScreen cancels category selection without retrying import',
    (tester) async {
      final ingredientRepository = _FakeIngredientCatalogueRepository(
        requiresCategory: true,
      );

      await pumpAddIngredientScreen(
        tester,
        ingredientRepository: ingredientRepository,
      );

      await tester.enterText(find.byType(TextField).first, 'kimchi');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kimchi'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a category'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      //only the original request with category_id null was made
      expect(ingredientRepository.importedCategoryIds, [null]);
      expect(find.text('Choose a category'), findsNothing);
      expect(find.text('Kimchi'), findsOneWidget);
      expect(find.text('Category: Select an ingredient'), findsOneWidget);
    },
  );

  testWidgets(
    'AddIngredientScreen shows error when categories cannot be loaded',
    (tester) async {
      final ingredientRepository = _FakeIngredientCatalogueRepository(
        requiresCategory: true,
        shouldFailCategoryLoad: true,
      );

      await pumpAddIngredientScreen(
        tester,
        ingredientRepository: ingredientRepository,
      );

      await tester.enterText(find.byType(TextField).first, 'kimchi');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kimchi'));
      await tester.pumpAndSettle();

      expect(ingredientRepository.categoryRequestCount, 1);
      expect(ingredientRepository.importedCategoryIds, [null]);
      expect(find.text('Choose a category'), findsNothing);
      expect(
        find.text(
          'Could not import Kimchi. Try again.',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
    },
  );
}
