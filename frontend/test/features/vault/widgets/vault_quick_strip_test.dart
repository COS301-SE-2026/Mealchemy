import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/vault/widgets/vault_quick_strip.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

void main() {
  Widget buildWidget(List<Recipe> recipes) {
    return MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: VaultQuickStrip(recipes: recipes),
            ),
          ),
          GoRoute(
            path: '/recipe/:id',
            builder: (context, state) => const Scaffold(body: Text('Recipe Detail')),
          ),
        ],
      ),
    );
  }

  group('VaultQuickStrip', () {
    //Checking Rendering if the list of recipes is empty
    testWidgets('renders nothing when recipes are empty', (tester) async {
      await tester.pumpWidget(buildWidget([ ]));

      expect(find.byType(ListView), findsNothing);
    });

    //Checking Rendering if the list of recipes is not empty
    testWidgets('renders list when recipes are provided', (tester) async {
      await tester.pumpWidget(buildWidget([
        const Recipe(recipeId: 1, title: 'Pasta Vera', cuisineType: 'Italian'),
        const Recipe(recipeId: 2, title: 'Carbonara', cuisineType: 'Italian'),

      ]));
      expect(find.byType(ListView), findsOneWidget);
    });

    //Rendering recipe title and fallback icon when no photo is provided
    testWidgets('renders recipe title', (tester) async {
      await tester.pumpWidget(buildWidget([
        const Recipe(recipeId: 1, title: 'Pasta Vera', cuisineType: 'Italian'),
      ]));
      expect(find.text('Pasta Vera'), findsOneWidget);
    });

    //Rendering fallback icon when no photo is provided
    testWidgets('renders fallback icon when no photo', (tester) async {
      await tester.pumpWidget(buildWidget([
        const Recipe(recipeId: 1, title: 'Pasta Vera', cuisineType: 'Italian'),
      ]));
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
    });

    //Tapping a recipe thumbnail navigates to the recipe detail screen
    testWidgets('tapping a thumbnail navigates to recipe detail', (tester) async {
      await tester.pumpWidget(buildWidget([
        const Recipe(recipeId: 1, title: 'Pasta Vera', cuisineType: 'Italian'),
      ]));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(find.text('Recipe Detail'), findsOneWidget);
    });
  });
}