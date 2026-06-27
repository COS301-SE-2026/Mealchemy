import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/guided_discovery/repositories/mock_guided_discovery_repository.dart';

void main() {
  //make sure it actually returns mock recipe data
  test('MockGuidedDiscoveryRepository returns discovery recipe data', () async {
    //mock repo instance (no API)
    final repository = MockGuidedDiscoveryRepository();

    final recipes = await repository.getDiscoveryRecipes();

    //expected mock data
    expect(recipes, isNotEmpty);
    expect(recipes.first.id, isNotEmpty);
    expect(recipes.first.title, isNotEmpty);
    expect(recipes.first.chefName, isNotEmpty);
    expect(recipes.first.imageUrl, isNotEmpty);
    expect(recipes.first.matchPercentage, greaterThan(0));
    expect(recipes.first.tags, isNotEmpty);
    expect(recipes.first.ingredients, isNotEmpty);
    expect(recipes.first.steps, isNotEmpty);
    expect(recipes.first.matchReason, isNotEmpty);
  });
}