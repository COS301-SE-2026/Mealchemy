import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_hero.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/shopping_lists/repositories/mock_shopping_list_repository.dart';


class _ThrowingShoppingListRepo extends MockShoppingListRepository {
  @override
  Future<ShoppingList> generateFromRecipe({
    required int recipeId,
    required String name,
    required bool includeAvailablePantryItems,
  }) async =>
      throw Exception('generate failed');
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(Recipe recipe, {List<Override>? overrides}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              Scaffold(body: RecipeHero(recipe: recipe)),
        ),
      ],
    );
    return ProviderScope(
      overrides: overrides ??
          [
            shoppingListRepositoryProvider
                .overrideWithValue(MockShoppingListRepository()),
          ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  const baseRecipe = Recipe(recipeId: 1, title: 'Saffron-Infused Risotto');

  testWidgets('RecipeHero renders the recipe title', (tester) async {
    await tester.pumpWidget(host(baseRecipe));
    expect(find.text('Saffron-Infused Risotto'), findsOneWidget);
  });

  testWidgets('RecipeHero shows placeholder icon when photoUrl is null',
      (tester) async {
    await tester.pumpWidget(host(baseRecipe));
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });

  testWidgets('RecipeHero renders back, shopping-list and save buttons',
      (tester) async {

    await tester.pumpWidget(host(baseRecipe));
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_add_outlined), findsOneWidget);
  });

  testWidgets('tapping the shopping-list button shows a success snackbar',
      (tester) async {
    await tester.pumpWidget(host(baseRecipe));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_shopping_cart));
    await tester.pumpAndSettle();
    expect(
      find.text('Shopping list created for Saffron-Infused Risotto'),
      findsOneWidget,
    );
  });
}