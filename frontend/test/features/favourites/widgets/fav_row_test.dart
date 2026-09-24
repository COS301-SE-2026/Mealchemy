import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/favourites/models/favourite.dart';
import 'package:mealchemy/features/favourites/providers/fav_provider.dart';
import 'package:mealchemy/features/favourites/repositories/fav_repository.dart';
import 'package:mealchemy/features/favourites/widgets/fav_row.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

class _FakeFavRepository implements FavRepository {
  final List<int> removed = [];

  @override
  Future<List<Favourite>> getFavs() async => [];

  @override
  Future<void> removeFav(int recipeId) async => removed.add(recipeId);
}

Favourite _fav() => Favourite(
      favouriteId: 1,
      recipeId: 1,
      createdAt: DateTime(2026, 2, 14),
      recipe: Recipe(
        recipeId: 1,
        title: 'Test Pasta',
        cuisineType: 'italian',
        prepTimeMins: 10,
        cookingTimeMins: 20,
      ),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late _FakeFavRepository repo;
  late String? pushedRoute;

  Widget host({bool mutationsEnabled = true}) {
    repo = _FakeFavRepository();
    pushedRoute = null;

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: FavRow(fav: _fav(), mutationsEnabled: mutationsEnabled),
          ),
        ),
        GoRoute(
          path: '/recipe/:id',
          builder: (context, state) {
            pushedRoute = '/recipe/${state.pathParameters['id']}';
            return const Scaffold(body: SizedBox());
          },
        ),
      ],
    );

    return ProviderScope(
      overrides: [favRepositoryProvider.overrideWith((ref) => repo)],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }

  testWidgets('renders the recipe title and time/cuisine subtitle ',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('Test Pasta'), findsOneWidget);
    expect(find.text('30 mins · Italian'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('tapping the  heart removes the favourite', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();
    expect(repo.removed, [1]);

  });

  testWidgets('tapping the row navigates to the recipe', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test Pasta'));
    await tester.pumpAndSettle();
    expect(pushedRoute, '/recipe/1');
  });

  testWidgets('disables the remove action when mutations are off',
      (tester) async {
    await tester.pumpWidget(host(mutationsEnabled: false));
    await tester.pumpAndSettle();
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
    expect(find.byTooltip('Unavailable offline'), findsOneWidget);
  });
}