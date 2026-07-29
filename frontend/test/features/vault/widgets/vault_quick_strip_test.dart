import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/vault/widgets/vault_quick_strip.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget buildWidget(List<Recipe> recipes) {
    return MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) =>
                Scaffold(body: VaultQuickStrip(recipes: recipes)),
          ),
          GoRoute(
            path: '/recipe/:id',
            builder: (_, __) => const Scaffold(body: Text('Recipe Detail')),
          ),
        ],
      ),
    );
  }

  group('VaultQuickStrip', () {
    //Checking rendering when the list of recipes is empty
    testWidgets('renders nothing when recipes are empty', (tester) async {
      await tester.pumpWidget(buildWidget(const []));
      expect(find.byType(ListView), findsNothing);
    });

    //Checking rendering when the list of recipes is not empty
    testWidgets('renders a list when recipes are provided', (tester) async {
      await tester.pumpWidget(buildWidget(const [
        Recipe(recipeId: 1, title: 'Pasta Vera', cuisineType: 'Italian'),
        Recipe(recipeId: 2, title: 'Carbonara', cuisineType: 'Italian'),
      ]));
      expect(find.byType(ListView), findsOneWidget);
    });

    //Rendering the recipe title
    testWidgets('renders the recipe title', (tester) async {
      await tester.pumpWidget(buildWidget(const [
        Recipe(recipeId: 1, title: 'Pasta Vera', cuisineType: 'Italian'),
      ]));
      expect(find.text('Pasta Vera'), findsOneWidget);
    });

    //Rendering the fallback icon when no photo is provided
    testWidgets('renders the fallback icon when there is no photo',
        (tester) async {
      await tester.pumpWidget(buildWidget(const [
        Recipe(recipeId: 1, title: 'Pasta Vera', cuisineType: 'Italian'),
      ]));
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
    });

    //Tapping a thumbnail navigates to the recipe detail screen
    testWidgets('tapping a thumbnail navigates to recipe detail',
        (tester) async {
      await tester.pumpWidget(buildWidget(const [
        Recipe(recipeId: 1, title: 'Pasta Vera', cuisineType: 'Italian'),
      ]));

      await tester.tap(find.byIcon(Icons.restaurant_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Recipe Detail'), findsOneWidget);
    });
  });
}