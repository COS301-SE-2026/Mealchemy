import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/constants/app_config.dart';
import 'package:mealchemy/features/discovery/models/discovery_category.dart';
import 'package:mealchemy/features/discovery/repositories/api_discovery_repository.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';
import 'package:mealchemy/features/discovery/repositories/mock_discovery_repository.dart';

//Switch between the mock and API repository based on the app configuration
final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockDiscoveryRepository();
  }
  return ApiDiscoveryRepository();
});

//State

class DiscoveryState {
  final bool isLoading;
  final String? errorMessage;
  final List<DiscoveryCategory> categories;
  final int? selectedCategoryId;

  const DiscoveryState({
    this.isLoading = false,
    this.errorMessage,
    this.categories = const [],
    this.selectedCategoryId ,
  });

  DiscoveryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<DiscoveryCategory>? categories,
    int? selectedCategoryId,
  }) {
    return DiscoveryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
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
      final categories = await _repository.getCategories();
      state = state.copyWith(
        isLoading: false,
        categories: categories,
        selectedCategoryId: categories.isNotEmpty ? categories.first.id : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load discovery. Please try again.',
      );
    }
  }

  void selectCategory(int id) {
    state = state.copyWith(selectedCategoryId: id);
  }
}

// Provider
final discoveryProvider =
    StateNotifierProvider<DiscoveryNotifier, DiscoveryState>((ref) {
  return DiscoveryNotifier(ref.watch(discoveryRepositoryProvider));
});