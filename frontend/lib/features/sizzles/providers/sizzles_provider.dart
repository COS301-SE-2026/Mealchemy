import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_service_provider.dart';
import '../../recipe/models/recipe.dart';
import '../repositories/api_sizzles_repository.dart';
import '../repositories/sizzles_repository.dart';

final sizzlesRepositoryProvider = Provider<SizzlesRepository>((ref) {
  return ApiSizzlesRepository(ref.read(dioProvider));
});

final sizzlesProvider =
    AsyncNotifierProvider.autoDispose<SizzlesNotifier, SizzlesState>(
  SizzlesNotifier.new,
);

class SizzlesState {
  const SizzlesState({
    this.items = const [],
    this.currentIndex = 0,
  });

  final List<Recipe> items;
  final int currentIndex;

  SizzlesState copyWith({
    List<Recipe>? items,
    int? currentIndex,
  }) {
    return SizzlesState(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class SizzlesNotifier extends AutoDisposeAsyncNotifier<SizzlesState> {
  SizzlesRepository get _repository => ref.read(sizzlesRepositoryProvider);

  @override
  Future<SizzlesState> build() async {
    final items = await _repository.getSizzles();
    return SizzlesState(items: items);
  }

  Future<void> reset() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  void onPageChanged(int index) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(currentIndex: index));
  }
}
