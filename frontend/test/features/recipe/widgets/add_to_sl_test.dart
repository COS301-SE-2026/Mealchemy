import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/widgets/add_to_sl.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/shopping_lists/repositories/shopping_list_repository.dart';

ShoppingList _list(String id, String title) => ShoppingList(
      id: id,
      title: title,
      subtitle: '',
      section: 'OTHER LISTS',
      iconType: 'list',
      items: const [],
    );


class _FakeSlRepo implements ShoppingListRepository {
  _FakeSlRepo(this._seed);
  final List<ShoppingList> _seed;

  final List<({int recipeId, String name, bool includeAvailable})> generated =
      [];
  final List<({String listId, int recipeId, bool includeAvailable})> added = [];
  bool throwOnWrite = false;

  @override
  Future<List<ShoppingList>> getShoppingLists() async => _seed;

  @override
  Future<ShoppingList> generateFromRecipe({
    required int recipeId,
    required String name,
    required bool includeAvailablePantryItems,
  }) async {
    if (throwOnWrite) throw Exception('generate failed');
    generated.add((
      recipeId: recipeId,
      name: name,
      includeAvailable: includeAvailablePantryItems,
    ));
    return _list('new-1', name);
  }

  @override
  Future<ShoppingList> addRecipeToExistingList({
    required String listId,
    required int recipeId,
    required bool includeAvailablePantryItems,
  }) async {
    if (throwOnWrite) throw Exception('add failed');
    added.add((
      listId: listId,
      recipeId: recipeId,
      includeAvailable: includeAvailablePantryItems,
    ));
    return _list(listId, 'Existing');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host(_FakeSlRepo repo) {
    return ProviderScope(
      overrides: [
        shoppingListRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => showAddToSl(
                    context: context,
                    ref: ref,
                    recipeId: 42,
                    recipeName: 'Test Pasta',
                  ),
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('defaults to a new list, prefilled with the recipe name',
      (tester) async {
    await tester.pumpWidget(host(_FakeSlRepo([])));
    await openSheet(tester);

    expect(find.widgetWithText(TextField, 'Test Pasta'), findsOneWidget);
    expect(find.text('Create List'), findsOneWidget);
    expect(find.text('Add to List'), findsNothing);
  });

  testWidgets('creating a new list routes to generateFromRecipe',
      (tester) async {
    final repo = _FakeSlRepo([]);
    await tester.pumpWidget(host(repo));
    await openSheet(tester);

    await tester.tap(find.text('Create List'));
    await tester.pumpAndSettle();

    expect(repo.generated,
        [(recipeId: 42, name: 'Test Pasta', includeAvailable: true)]);
    expect(repo.added, isEmpty);
    expect(find.text('Create Shopping List'), findsNothing); // sheet closed
  });

  testWidgets('a blank new-list name is rejected before any repo call',
      (tester) async {
    final repo = _FakeSlRepo([]);
    await tester.pumpWidget(host(repo));
    await openSheet(tester);

    await tester.enterText(
        find.widgetWithText(TextField, 'Test Pasta'), '   ');
    await tester.tap(find.text('Create List'));
    await tester.pumpAndSettle();

    expect(repo.generated, isEmpty);
    expect(find.text('Create Shopping List'), findsOneWidget); // stays open
  });

  testWidgets('picking an existing list routes to addRecipeToExistingList',
      (tester) async {
    final repo = _FakeSlRepo([_list('7', 'Weekend Cooking')]);
    await tester.pumpWidget(host(repo));
    await openSheet(tester);

    await tester.tap(find.text('New list'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekend Cooking').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Test Pasta'), findsNothing);

    await tester.tap(find.text('Add to List'));
    await tester.pumpAndSettle();

    expect(repo.added,
        [(listId: '7', recipeId: 42, includeAvailable: true)]);
    expect(repo.generated, isEmpty);
  });

  testWidgets('turning off Smart add sends includeAvailable false',
      (tester) async {
    final repo = _FakeSlRepo([]);
    await tester.pumpWidget(host(repo));
    await openSheet(tester);

    await tester.tap(find.text('Smart add'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create List'));
    await tester.pumpAndSettle();

    expect(repo.generated,
        [(recipeId: 42, name: 'Test Pasta', includeAvailable: false)]);
  });

  testWidgets('a failed create keeps the sheet open', (tester) async {
    final repo = _FakeSlRepo([])..throwOnWrite = true;
    await tester.pumpWidget(host(repo));
    await openSheet(tester);

    await tester.tap(find.text('Create List'));
    await tester.pumpAndSettle();

    expect(find.text('Create Shopping List'), findsOneWidget);
  });
}