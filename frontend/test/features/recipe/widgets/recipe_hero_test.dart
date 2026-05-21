import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_hero.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  //RecipeHero uses context.pop() so the tree needs a GoRouter
  Widget host(Recipe recipe) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(body: RecipeHero(recipe: recipe)),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  const baseRecipe = Recipe(recipeId: 1, title: 'Saffron-Infused Risotto');

  testWidgets('RecipeHero renders the recipe title', (tester) async {
    await tester.pumpWidget(host(baseRecipe));

    expect(find.text('Saffron-Infused Risotto'), findsOneWidget);
  });

  testWidgets('RecipeHero shows placeholder icon when photoUrl is null', (
    tester,
  ) async {
    await tester.pumpWidget(host(baseRecipe));

    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });

  testWidgets('RecipeHero renders back, favorite and share buttons', (
    tester,
  ) async {
    await tester.pumpWidget(host(baseRecipe));

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.share_outlined), findsOneWidget);
  });
}
