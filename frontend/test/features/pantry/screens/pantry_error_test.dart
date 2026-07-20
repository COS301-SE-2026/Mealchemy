import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/pantry/models/pantry_ingredient.dart';
import 'package:mealchemy/features/pantry/models/pantry_summary.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';
import 'package:mealchemy/features/pantry/repositories/pantry_repository.dart';
import 'package:mealchemy/features/pantry/screens/add_ingredient_screen.dart';
import 'package:mealchemy/features/pantry/screens/pantry_screen.dart';

//mock repo to simulate pantry API
class _FailingPantryRepository implements PantryRepository {
  @override
  //simulate different failures
  Future<PantrySummary> getPantrySummary() {
    throw Exception('Summary failure');
  }

  @override
  Future<List<PantryFilter>> getPantryFilters() {
    throw Exception('Filter failure');
  }

  @override
  Future<List<PantryIngredient>> getPantryIngredients() {
    throw Exception('Ingredient failure');
  }

  @override
  Future<List<String>> getIngredientCategories() {
    throw Exception('Category failure');
  }

  @override
  Future<PantryIngredient> addPantryIngredient({
    required int ingId,
    required String quantity,
    required String unit,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deletePantryIngredient(int pIngredientId) {
    throw UnimplementedError();
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('PantryScreen renders error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider
              .overrideWithValue(_FailingPantryRepository()),
        ],
        child: const MaterialApp(
          home: PantryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unable to load pantry data.'), findsOneWidget);
  });

  testWidgets('AddIngredientScreen renders category error state',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider
              .overrideWithValue(_FailingPantryRepository()),
        ],
        child: const MaterialApp(
          home: AddIngredientScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unable to load ingredient categories.'), findsOneWidget);
  });
}
