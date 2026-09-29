import '../models/preference_weights.dart';

abstract class WeightsRepository {
  Future<PreferenceWeights> getWeights();
  Future<PreferenceWeights> saveWeights(PreferenceWeights weights);
}