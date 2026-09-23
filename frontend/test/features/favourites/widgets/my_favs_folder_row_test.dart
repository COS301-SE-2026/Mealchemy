import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/favourites/models/favourite.dart';
import 'package:mealchemy/features/favourites/providers/fav_provider.dart';
import 'package:mealchemy/features/favourites/repositories/fav_repository.dart';
import 'package:mealchemy/features/favourites/widgets/fav_row.dart';
import 'package:mealchemy/features/favourites/widgets/my_favs_folder_row.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

class _ListFavRepository implements FavRepository {
  _ListFavRepository(this.favs);
  final List<Favourite> favs;
  @override
  Future<List<Favourite>> getFavs() async => favs;
  @override
  Future<void> removeFav(int recipeId) async {}
}

class _ErrorFavRepository implements FavRepository {
  @override
  Future<List<Favourite>> getFavs() async => throw Exception('boom');
  @override
  Future<void> removeFav(int recipeId) async {}
}

class _PendingFavRepository implements FavRepository {
  @override
  Future<List<Favourite>> getFavs() => Completer<List<Favourite>>().future;
  @override
  Future<void> removeFav(int recipeId) async {}
}

Favourite _fav() => Favourite(
      favouriteId: 1,
      recipeId: 1,
      createdAt: DateTime(2026, 2, 14),
      recipe: const Recipe(recipeId: 1, title: 'Test Pasta'),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host(FavRepository repo) {
    return ProviderScope(
      overrides: [
        favRepositoryProvider.overrideWith((ref) => repo),
        offlineReadOnlyProvider.overrideWith((ref) => false),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const Scaffold(
                body: SingleChildScrollView(child: MyFavsFolderRow()),
              ),
            ),
            GoRoute(
              path: '/recipe/:id',
              builder: (_, __) => const Scaffold(body: Text('Recipe Detail')),
            ),
          ],
        ),
      ),
    );
  }

  group('MyFavsFolderRow', () {
    testWidgets('renders the tile and closed heart icon', (tester) async {
      await tester.pumpWidget(host(_ListFavRepository([_fav()])));
      await tester.pumpAndSettle();
      expect(find.text('Favourites'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('shows the favourite count in the metadata line',
        (tester) async {
      await tester.pumpWidget(host(_ListFavRepository([_fav()])));
      await tester.pumpAndSettle();

      expect(find.text('1 favourite'), findsOneWidget);
    });

    testWidgets('expands when tapped, swaping to the filled heart icon',
        (tester) async {
      await tester.pumpWidget(host(_ListFavRepository([_fav()])));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      expect(find.byType(FavRow), findsOneWidget);
      expect(find.text('Test Pasta'), findsOneWidget);
    });

    testWidgets('shows the empty state when there are no favourites',
        (tester) async {
      await tester.pumpWidget(host(_ListFavRepository([])));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      expect(find.text('No favourites yet.'), findsOneWidget);
    });

    testWidgets('show the error state  when the load fails', (tester) async {
      await tester.pumpWidget(host(_ErrorFavRepository()));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      expect(find.text('Unable to load favourites.'), findsOneWidget);
    });

    testWidgets('shows a spinner while favourites load', (tester) async {
      await tester.pumpWidget(host(_PendingFavRepository()));
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}