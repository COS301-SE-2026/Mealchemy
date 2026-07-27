import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/constants/app_config.dart';
import 'package:mealchemy/core/providers/api_service_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/discovery/repositories/api_discovery_repository.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';
import 'package:mealchemy/features/discovery/repositories/mock_discovery_repository.dart';


//Switch between the mock and API repository based on the app configuration
final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  if (AppConfig.mockDiscovery) {
    return MockDiscoveryRepository();
  }
  return ApiDiscoveryRepository(ref.read(dioProvider));
});

//State

class DiscoveryState {
  final bool isLoading;
  final String? errorMessage;
  final List<Recipe> recipes;
  final List<String> cuisines;
  final String? selectedCuisine; 

  const DiscoveryState({
    this.isLoading = false,
    this.errorMessage,
    this.recipes = const [],
    this.selectedCuisine,
    this.cuisines = const [],
  });

   List<Recipe> get visibleRecipes {
    if (selectedCuisine == null) return recipes;
    return recipes.where((r) => r.cuisineType == selectedCuisine).toList();
  }
  DiscoveryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<String>? cuisines,
    String? selectedCuisine,
    bool clearSelectedCuisine = false,
    List<Recipe>? recipes,
  }) {
    return DiscoveryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      cuisines: cuisines ?? this.cuisines,
      selectedCuisine: clearSelectedCuisine ? null : (selectedCuisine ?? this.selectedCuisine),
      recipes: recipes ?? this.recipes,
    );
  }
}

//Notifier
class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  DiscoveryNotifier(this._repository) : super(const DiscoveryState());
  final DiscoveryRepository _repository;

  Future<void> loadDiscovery() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final recipes = await _repository.getPublishedRecipes();
      final cuisines = await _repository.getCuisineTypes();
      state = state.copyWith(
        isLoading: false,
        recipes: recipes,
        cuisines: cuisines,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load discovery. Please try again.',
      );
    }
  }

  //null clears the filter (All)
  void selectCuisine(String? cuisine) {
    if (cuisine == null) {
      state = state.copyWith(clearSelectedCuisine: true);
    } else {
      state = state.copyWith(selectedCuisine: cuisine);
    }
  }
}

final discoveryProvider =
    StateNotifierProvider<DiscoveryNotifier, DiscoveryState>((ref) {
  return DiscoveryNotifier(ref.watch(discoveryRepositoryProvider));
});