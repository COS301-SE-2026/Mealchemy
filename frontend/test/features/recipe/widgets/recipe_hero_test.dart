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

  testWidgets('RecipeHero shows chef name and rating when provided', (
    tester,
  ) async {
    const recipe = Recipe(
      recipeId: 1,
      title: 'Saffron-Infused Risotto',
      chefName: 'Chef Isabella V.',
      rating: 4.8,
    );

    await tester.pumpWidget(host(recipe));

    expect(find.text('Chef Isabella V.'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('RecipeHero hides chef row when chefName is null', (tester) async {
    await tester.pumpWidget(host(baseRecipe));

    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.byIcon(Icons.person), findsNothing);
  });

  testWidgets('RecipeHero shows fallback person icon when chefName set but avatar null', (
    tester,
  ) async {
    const recipe = Recipe(
      recipeId: 1,
      title: 'Test',
      chefName: 'Anonymous Cook',
    );

    await tester.pumpWidget(host(recipe));

    expect(find.text('Anonymous Cook'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
