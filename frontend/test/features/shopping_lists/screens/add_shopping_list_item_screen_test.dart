import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mealchemy/features/pantry/models/ingredient_catalogue_item.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';
import 'package:mealchemy/features/pantry/repositories/ingredient_catalogue_repository.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list_item.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/shopping_lists/repositories/mock_shopping_list_repository.dart';
import 'package:mealchemy/features/shopping_lists/screens/add_shopping_list_item_screen.dart';

class _FakeIngredientCatalogueRepository extends IngredientCatalogueRepository {
  _FakeIngredientCatalogueRepository({
    this.shouldFail = false,
    this.returnExternalIngredient = false,
  }) : super(Dio());

  final bool shouldFail;
  final bool returnExternalIngredient;

  String? lastSearchQuery;
  String? lastImportedSourceId;
  int? lastImportedCategoryId;

  @override
  Future<List<IngredientCatalogueItem>> searchIngredients(String query) async {
    lastSearchQuery = query;

    if (shouldFail) {
      throw Exception('Catalogue unavailable.');
    }

    if (returnExternalIngredient) {
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

    return const IngredientCatalogueItem(
      ingId: 25,
      name: 'Kimchi',
      category: 'Vegetables',
    );
  }
}

class _RecordingShoppingListRepository extends MockShoppingListRepository {
  _RecordingShoppingListRepository({
    this.shouldFail = false,
  });

  final bool shouldFail;

  String? addedListId;
  int? addedIngId;
  String? addedName;
  String? addedQuantity;
  String? addedUnit;

  @override
  Future<ShoppingListItem> addItemToShoppingList({
    required String listId,
    int? ingId,
    String? name,
    required String quantity,
    required String unit,
  }) async {
    if (shouldFail) {
      throw Exception('Unable to create item.');
    }

    addedListId = listId;
    addedIngId = ingId;
    addedName = name;
    addedQuantity = quantity;
    addedUnit = unit;

    return ShoppingListItem(
      id: 'new-item',
      itemId: 999,
      shoppingListId: int.tryParse(listId),
      ingId: ingId,
      name: name ?? 'Milk',
      quantity: '$quantity $unit',
      category: ingId == null ? 'MANUAL' : 'DAIRY',
      unit: unit,
    );
  }
}

class _ScreenHarness {
  const _ScreenHarness({
    required this.shoppingRepository,
    required this.catalogueRepository,
  });

  final _RecordingShoppingListRepository shoppingRepository;
  final _FakeIngredientCatalogueRepository catalogueRepository;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<_ScreenHarness> pumpEntryScreen(
    WidgetTester tester, {
    bool catalogueShouldFail = false,
    bool catalogueReturnsExternal = false,
    bool shoppingShouldFail = false,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final shoppingRepository = _RecordingShoppingListRepository(
      shouldFail: shoppingShouldFail,
    );
    final catalogueRepository = _FakeIngredientCatalogueRepository(
      shouldFail: catalogueShouldFail,
      returnExternalIngredient: catalogueReturnsExternal,
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: '/shopping-lists/:id/add-item',
          builder: (context, state) {
            return AddShoppingListItemScreen(
              listId: state.pathParameters['id']!,
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(
            shoppingRepository,
          ),
          ingredientCatalogueRepositoryProvider.overrideWithValue(
            catalogueRepository,
          ),
        ],
        child: MaterialApp.router(
          theme: ThemeData(
            splashFactory: NoSplash.splashFactory,
          ),
          routerConfig: router,
        ),
      ),
    );

    router.push('/shopping-lists/general-list/add-item');
    await tester.pumpAndSettle();

    return _ScreenHarness(
      shoppingRepository: shoppingRepository,
      catalogueRepository: catalogueRepository,
    );
  }

  testWidgets('shows an error when catalogue search fails', (tester) async {
    await pumpEntryScreen(
      tester,
      catalogueShouldFail: true,
    );

    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Search catalogue, e.g. Chicken Breast',
      ),
      'milk',
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Could not search the catalogue. Try again.'),
      findsOneWidget,
    );
  });

  testWidgets('shows an error when adding a custom item fails', (
    tester,
  ) async {
    await pumpEntryScreen(
      tester,
      shoppingShouldFail: true,
    );

    await tester.tap(find.text('Custom Item'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'e.g. Cupcakes'),
      'Cupcakes',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'e.g. 1.5'),
      '6',
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('pcs').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Item'));
    await tester.pump();

    expect(
      find.text('Could not add the item. Try again.'),
      findsOneWidget,
    );
  });

  testWidgets('renders catalogue entry form by default', (tester) async {
    await pumpEntryScreen(tester);

    expect(find.text('Shopping List Entry'), findsOneWidget);
    expect(find.text('Add Shopping List Item'), findsOneWidget);
    expect(find.text('Catalogue'), findsOneWidget);
    expect(find.text('Custom Item'), findsOneWidget);
    expect(find.text('Ingredient Name'), findsOneWidget);
    //quantity appears as both the section heading and field label
    expect(find.text('Quantity'), findsNWidgets(2));
    expect(find.text('Unit'), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);
  });

  testWidgets('validates missing catalogue item quantity and unit', (
    tester,
  ) async {
    await pumpEntryScreen(tester);

    await tester.tap(find.text('Add Item'));
    await tester.pump();

    expect(
      find.text('Please select an ingredient from the catalogue.'),
      findsOneWidget,
    );
    expect(
      find.text('Enter a quantity greater than zero.'),
      findsOneWidget,
    );
    expect(find.text('Unit is required.'), findsOneWidget);
  });

  testWidgets('submits a selected catalogue ingredient', (tester) async {
    final harness = await pumpEntryScreen(tester);

    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Search catalogue, e.g. Chicken Breast',
      ),
      'milk',
    );
    await tester.pumpAndSettle();

    expect(harness.catalogueRepository.lastSearchQuery, 'milk');
    expect(find.text('Milk'), findsOneWidget);

    await tester.tap(find.text('Milk'));
    await tester.pumpAndSettle();

    expect(find.text('Category: Dairy'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'e.g. 1.5'),
      '1.5',
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('L').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Item'));
    await tester.pump();

    expect(harness.shoppingRepository.addedListId, 'general-list');
    expect(harness.shoppingRepository.addedIngId, 12);
    expect(harness.shoppingRepository.addedName, isNull);
    expect(harness.shoppingRepository.addedQuantity, '1.5');
    expect(harness.shoppingRepository.addedUnit, 'L');
  });

  testWidgets('imports and selects a USDA catalogue ingredient', (
    tester,
  ) async {
    final harness = await pumpEntryScreen(
      tester,
      catalogueReturnsExternal: true,
    );

    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Search catalogue, e.g. Chicken Breast',
      ),
      'kimchi',
    );
    await tester.pumpAndSettle();

    expect(find.text('Kimchi'), findsOneWidget);
    expect(find.text('USDA result'), findsOneWidget);

    await tester.tap(find.text('Kimchi'));
    await tester.pumpAndSettle();

    expect(harness.catalogueRepository.lastImportedSourceId, '2710077');
    expect(harness.catalogueRepository.lastImportedCategoryId, isNull);
    expect(find.text('Category: Vegetables'), findsOneWidget);
  });

  testWidgets('submits a custom item without an ingredient id', (
    tester,
  ) async {
    final harness = await pumpEntryScreen(tester);

    await tester.tap(find.text('Custom Item'));
    await tester.pumpAndSettle();

    expect(find.text('Custom Item Name'), findsOneWidget);
    expect(find.text('Ingredient Name'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'e.g. Cupcakes'),
      'Cupcakes',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'e.g. 1.5'),
      '6',
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('pcs').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Item'));
    await tester.pump();

    expect(harness.shoppingRepository.addedListId, 'general-list');
    expect(harness.shoppingRepository.addedIngId, isNull);
    expect(harness.shoppingRepository.addedName, 'Cupcakes');
    expect(harness.shoppingRepository.addedQuantity, '6');
    expect(harness.shoppingRepository.addedUnit, 'pcs');
  });
}
