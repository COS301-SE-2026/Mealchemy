import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/providers/api_service_provider.dart';
import '../models/ingredient_catalogue_item.dart';
import '../repositories/api_ingredient_catalogue_repository.dart';
import '../repositories/ingredient_catalogue_repository.dart';
import '../repositories/mock_ingredient_catalogue_repository.dart';

final ingredientCatalogueRepositoryProvider =
    Provider<IngredientCatalogueRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockIngredientCatalogueRepository();
  }
  return ApiIngredientCatalogueRepository(ref.read(dioProvider));
});


final catalogueSearchProvider =
    FutureProvider.family<List<IngredientCatalogueItem>, String>((ref, query) {
  final repo = ref.watch(ingredientCatalogueRepositoryProvider);
  return query.trim().isEmpty ? repo.getAll() : repo.search(query);
});