import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_service_provider.dart';
import '../models/favourite.dart';
import '../repositories/api_fav_repository.dart';
import '../repositories/fav_repository.dart';

final favRepositoryProvider = Provider<FavRepository>((ref) {
  return ApiFavRepository(ref.read(dioProvider));
});

final favsProvider = AsyncNotifierProvider<FavsNotifier, List<Favourite>>(
  FavsNotifier.new,
);

class FavsNotifier extends AsyncNotifier<List<Favourite>> {
  FavRepository get _repository => ref.read(favRepositoryProvider);

  @override
  Future<List<Favourite>> build() {
    return _repository.getFavs();
  }

  Future<void> removeFav(int recipeId) async {
    final current = state.valueOrNull ?? [];
    final fav = current.where((f) => f.recipeId == recipeId).firstOrNull;

    await _repository.removeFav(
      recipeId,
      cuisineValue: fav?.cuisineValue ?? 'OTHER',
    );
    state = AsyncData(
      current.where((fav) => fav.recipeId != recipeId).toList(),
    );
  }
}