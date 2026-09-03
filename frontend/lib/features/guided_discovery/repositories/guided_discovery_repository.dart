import '../models/recommendation.dart';
import '../models/swipe.dart';

class EmptyRecommendationPool implements Exception {
  const EmptyRecommendationPool();
}
abstract class GuidedDiscoveryRepository {
  // Fetches the next batch of recommendations.
  Future<List<Recommendation>> getRecommendations({
    int batchSize,
    List<int> excludeRecipeIds,
  });
  Future<SwipeResponse> recordSwipe(SwipeRequest request);
}