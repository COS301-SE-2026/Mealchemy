import '../models/discovery_recipe.dart';
import 'guided_discovery_repository.dart';

//mock Guided Discovery using mock repo
class MockGuidedDiscoveryRepository implements GuidedDiscoveryRepository {
  @override
  //list of mock recipes
  Future<List<DiscoveryRecipe>> getDiscoveryRecipes() async {
    return const [
      DiscoveryRecipe(
        id: 'short-rib-pappardelle',
        title: 'Braised Short Rib Pappardelle',
        chefName: 'Chef Isabella',
        imageUrl:
            'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=1400&q=90',
        matchPercentage: 92,
        cookTimeMinutes: 45,
        calories: 420,
        proteinGrams: 12,
        carbsGrams: 54,
        fatGrams: 18,
        tags: ['Comfort', 'Italian', 'High Protein'],
        ingredients: ['beef short rib', 'pappardelle', 'tomato', 'parmesan'],
      ),
      DiscoveryRecipe(
        id: 'miso-salmon-rice-bowl',
        title: 'Miso Salmon Rice Bowl',
        chefName: 'Chef Naomi',
        imageUrl:
            'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=1400&q=90',
        matchPercentage: 89,
        cookTimeMinutes: 32,
        calories: 510,
        proteinGrams: 36,
        carbsGrams: 42,
        fatGrams: 20,
        tags: ['High Protein', 'Quick Meals'],
        ingredients: ['salmon', 'rice', 'miso', 'cucumber', 'sesame'],
      ),
      DiscoveryRecipe(
        id: 'roasted-harissa-cauliflower',
        title: 'Roasted Harissa Cauliflower',
        chefName: 'Chef Amara',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1400&q=90',
        matchPercentage: 86,
        cookTimeMinutes: 28,
        calories: 390,
        proteinGrams: 14,
        carbsGrams: 48,
        fatGrams: 15,
        tags: ['Vegetarian', 'Quick Meals'],
        ingredients: [
          'cauliflower',
          'chickpeas',
          'harissa',
          'herbs',
          'yoghurt'
        ],
      ),
    ];
  }
}
