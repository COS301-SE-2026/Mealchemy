// Holds the user's preference profile state.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../models/user_preferences.dart';
import '../repositories/api_preference_repository.dart';
import '../repositories/mock_preference_repository.dart';
import '../repositories/preference_repository.dart';

//select mock/API
final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockPreferenceRepository();
  }

  return ApiPreferenceRepository();
});

//editable preference profile
final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences>(
  UserPreferencesNotifier.new,
);

class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  late final PreferenceRepository _repository;

  @override
  Future<UserPreferences> build() {
    _repository = ref.watch(preferenceRepositoryProvider);
    return _repository.getUserPreferences();
  }

  //dietary directive
  void toggleDietaryDirective(String title) {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedDirectives = current.dietaryDirectives.map((directive) {
      if (directive.title != title) return directive;
      return directive.copyWith(selected: !directive.selected);
    }).toList();

    state = AsyncData(
      current.copyWith(dietaryDirectives: updatedDirectives),
    );
  }

  //allergies
  void selectAllergy(String allergy) {
    final current = state.valueOrNull;
    if (current == null || current.selectedAllergies.contains(allergy)) return;

    state = AsyncData(
      current.copyWith(
        selectedAllergies: [...current.selectedAllergies, allergy],
        availableAllergies:
            current.availableAllergies.where((item) => item != allergy).toList(),
      ),
    );
  }

  //available allergy
  void removeAllergy(String allergy) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        selectedAllergies:
            current.selectedAllergies.where((item) => item != allergy).toList(),
        availableAllergies: [...current.availableAllergies, allergy],
      ),
    );
  }

  //disliked ingredient
  void addDislikedIngredient(String ingredient) {
    final current = state.valueOrNull;
    final cleanedIngredient = ingredient.trim().toUpperCase();

    if (current == null ||
        cleanedIngredient.isEmpty ||
        current.dislikedIngredients.contains(cleanedIngredient)) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        dislikedIngredients: [
          ...current.dislikedIngredients,
          cleanedIngredient,
        ],
      ),
    );
  }

  //removes disliked ingredient
  void removeDislikedIngredient(String ingredient) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        dislikedIngredients: current.dislikedIngredients
            .where((item) => item != ingredient)
            .toList(),
      ),
    );
  }

  //flavour profile
  void toggleFlavourProfile(String label) {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedProfiles = current.flavourProfiles.map((profile) {
      if (profile.label != label) return profile;
      return profile.copyWith(selected: !profile.selected);
    }).toList();

    state = AsyncData(
      current.copyWith(flavourProfiles: updatedProfiles),
    );
  }

  //original mock/API data
  Future<void> resetPreferences() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getUserPreferences);
  }
}