import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/guided_discovery/providers/guided_discovery_provider.dart';

void main() {
  //loads initial mock discovery state
  test('GuidedDiscoveryProvider loads initial recipe stack', () async {
    //provider container for Riverpod tests
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = await container.read(guidedDiscoveryProvider.future);

    expect(state.recipes, isNotEmpty);
    expect(state.currentIndex, 0);
    expect(state.selectedFilter, 'All');
    expect(state.likedRecipeIds, isEmpty);
    expect(state.dislikedRecipeIds, isEmpty);
    expect(state.currentRecipe, isNotNull);
    expect(state.isComplete, isFalse);
  });

  //like recipe updates liked list and moves to next recipe
  test('GuidedDiscoveryProvider likes current recipe', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initialState = await container.read(guidedDiscoveryProvider.future);
    final firstRecipeId = initialState.currentRecipe!.id;

    container
        .read(guidedDiscoveryProvider.notifier)
        .likeCurrentRecipe();

    final updatedState = container.read(guidedDiscoveryProvider).value!;

    expect(updatedState.currentIndex, 1);
    expect(updatedState.likedRecipeIds, contains(firstRecipeId));
    expect(updatedState.dislikedRecipeIds, isEmpty);
  });

  //dislike recipe updates disliked list and moves to next recipe
  test('GuidedDiscoveryProvider dislikes current recipe', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initialState = await container.read(guidedDiscoveryProvider.future);
    final firstRecipeId = initialState.currentRecipe!.id;

    container
        .read(guidedDiscoveryProvider.notifier)
        .dislikeCurrentRecipe();

    final updatedState = container.read(guidedDiscoveryProvider).value!;

    expect(updatedState.currentIndex, 1);
    expect(updatedState.dislikedRecipeIds, contains(firstRecipeId));
    expect(updatedState.likedRecipeIds, isEmpty);
  });

  //updates selected filter and resets current recipe position
  test('GuidedDiscoveryProvider selects filter', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(guidedDiscoveryProvider.future);

    container
        .read(guidedDiscoveryProvider.notifier)
        .selectFilter('High Protein');

    final updatedState = container.read(guidedDiscoveryProvider).value!;

    expect(updatedState.selectedFilter, 'High Protein');
    expect(updatedState.currentIndex, 0);
    expect(
      updatedState.recipes.every(
        (recipe) => recipe.tags.contains('High Protein'),
      ),
      isTrue,
    );
  });

  //reset returns discovery flow to original state
  test('GuidedDiscoveryProvider resets discovery state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(guidedDiscoveryProvider.future);

    container
        .read(guidedDiscoveryProvider.notifier)
        .likeCurrentRecipe();

    await container
        .read(guidedDiscoveryProvider.notifier)
        .resetDiscovery();

    final resetState = container.read(guidedDiscoveryProvider).value!;

    expect(resetState.currentIndex, 0);
    expect(resetState.selectedFilter, 'All');
    expect(resetState.likedRecipeIds, isEmpty);
    expect(resetState.dislikedRecipeIds, isEmpty);
    expect(resetState.recipes, isNotEmpty);
  });
}