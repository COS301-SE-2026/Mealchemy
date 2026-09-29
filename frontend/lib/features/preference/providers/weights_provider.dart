import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/api_service_provider.dart';
import '../models/preference_weights.dart';
import '../repositories/api_weights_repository.dart';
import '../repositories/weights_repository.dart';

final weightsRepositoryProvider = Provider<WeightsRepository>((ref) {
 return ApiWeightsRepository(ref.read(dioProvider));
});

final weightsProvider =
    AsyncNotifierProvider<WeightsNotifier, PreferenceWeights>(
  WeightsNotifier.new,
);

class WeightsNotifier extends AsyncNotifier<PreferenceWeights> {
  WeightsRepository get _repository => ref.read(weightsRepositoryProvider);

  @override
  Future<PreferenceWeights> build() {
    return _repository.getWeights();
  }

  Future<void> save(PreferenceWeights weights) async {
    final saved = await _repository.saveWeights(weights.normalized());
    state = AsyncData(saved);
  }
}