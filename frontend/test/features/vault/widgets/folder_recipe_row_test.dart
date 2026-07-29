import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/vault/widgets/folder_recipe_row.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

 
  Widget host(Recipe recipe, {VoidCallback? onEditTap}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: FolderRecipeRow(recipe: recipe, onEditTap: onEditTap),
          ),
        ),
        GoRoute(
          path: '/recipe/:id',
          builder: (_, state) =>
              Scaffold(body: Text('detail ${state.pathParameters['id']}')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('renders the recipe title', (tester) async {
    await tester.pumpWidget(host(
      const Recipe(recipeId: 1, title: 'Saffron Risotto'),
    ));
    expect(find.text('Saffron Risotto'), findsOneWidget);
  });

  testWidgets('builds the subtitle from total time and capitalised cuisine',
      (tester) async {
    await tester.pumpWidget(host(
      const Recipe(
        recipeId: 1,
        title: 'Risotto',
        prepTimeMins: 15,
        cookingTimeMins: 30,
        cuisineType: 'italian',
      ),
    ));
    
    expect(find.text('45 mins · Italian'), findsOneWidget);
  });

  testWidgets('omits time when there is none', (tester) async {
    await tester.pumpWidget(host(
      const Recipe(recipeId: 1, title: 'Snack', cuisineType: 'asian'),
    ));
    
    expect(find.text('Asian'), findsOneWidget);
  });

  testWidgets('shows the placeholder thumb icon when there is no photo',
      (tester) async {
    await tester.pumpWidget(host(
      const Recipe(recipeId: 1, title: 'No Photo'),
    ));
    expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
  });

  testWidgets('tapping the row navigates to the recipe detail route',
      (tester) async {
    await tester.pumpWidget(host(
      const Recipe(recipeId: 7, title: 'Tap Me'),
    ));

    await tester.tap(find.text('Tap Me'));
    await tester.pumpAndSettle();

    expect(find.text('detail 7'), findsOneWidget);
  });

  testWidgets('tapping the edit button fires onEditTap', (tester) async {
    var edited = false;
    await tester.pumpWidget(host(
      const Recipe(recipeId: 1, title: 'Edit Me'),
      onEditTap: () => edited = true,
    ));

    await tester.tap(find.byIcon(Icons.edit_outlined));
    expect(edited, isTrue);
  });
}