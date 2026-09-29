import '../models/recommendation.dart';
import '../models/swipe.dart';
import '../models/discovery_tag.dart';

class EmptyRecommendationPool implements Exception {
  const EmptyRecommendationPool();
}

abstract class GuidedDiscoveryRepository {
  // Fetches the next batch of recommendations.
  Future<List<Recommendation>> getRecommendations({
    int batchSize,
    List<int> excludeRecipeIds,
    List<String>? dietaryTags,
    int? maxTotalTimeMins,
  });
  Future<SwipeResponse> recordSwipe(SwipeRequest request);
  Future<List<DiscoveryTag>> getDietaryTags();
}
