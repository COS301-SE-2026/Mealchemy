import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/sizzles/providers/sizzles_provider.dart';
import 'package:mealchemy/features/sizzles/repositories/sizzles_repository.dart';
import 'package:mealchemy/features/sizzles/screens/sizzles_screen.dart';

void main() {
  testWidgets('shows a muted global video recipe without a match score',
      (tester) async {
    final repository = _SizzlesRepository([_recipe(1, 'Pasta Sizzle')]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sizzlesRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizzlesScreen(
              videoBuilder: (url, active, muted) => ColoredBox(
                key: ValueKey('$url-$active-$muted'),
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pasta Sizzle'), findsOneWidget);
    expect(find.textContaining('match'), findsNothing);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Recipe'), findsOneWidget);
    expect(find.text('Unmute'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('https://cdn.test/pasta.mp4-true-true')),
      findsOneWidget,
    );
  });

  testWidgets('swipes vertically and activates only the visible video',
      (tester) async {
    final repository = _SizzlesRepository([
      _recipe(1, 'Pasta Sizzle'),
      _recipe(2, 'Curry Sizzle'),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sizzlesRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizzlesScreen(
              videoBuilder: (url, active, muted) => ColoredBox(
                key: ValueKey('$url-$active-$muted'),
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.byType(PageView), const Offset(0, -500), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Curry Sizzle'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('https://cdn.test/curry.mp4-true-true')),
      findsOneWidget,
    );
  });
}

Recipe _recipe(int id, String title) {
  final slug = title.split(' ').first.toLowerCase();
  return Recipe(
    recipeId: id,
    title: title,
    cuisineType: 'MEDITERRANEAN',
    videoUrl: 'https://cdn.test/$slug.mp4',
    isCommunityPublished: true,
  );
}

class _SizzlesRepository implements SizzlesRepository {
  _SizzlesRepository(this.items);

  final List<Recipe> items;

  @override
  Future<List<Recipe>> getSizzles() async => items;
}
