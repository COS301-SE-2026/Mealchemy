import '../models/discovery_recipe.dart';
import 'guided_discovery_repository.dart';

//mock Guided Discovery using mock repo
class MockGuidedDiscoveryRepository implements GuidedDiscoveryRepository {
  @override
  Future<List<DiscoveryRecipe>> getDiscoveryRecipes() async {
    return const [
      //list of mock recipes
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
        ingredients: [
          'beef short rib',
          'pappardelle',
          'tomato passata',
          'parmesan',
          'fresh herbs',
        ],
        description:
            'Slow-braised beef folded through silky pappardelle with a rich tomato base and a sharp parmesan finish.',
        steps: [
          'Brown the short rib until deeply caramelised.',
          'Simmer with tomato passata and herbs until tender.',
          'Cook pappardelle until al dente.',
          'Toss pasta through the sauce and finish with parmesan.',
        ],
        matchReason:
            'You tend to respond well to comforting, protein-forward meals with bold savoury flavours.',
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
        ingredients: [
          'salmon fillet',
          'steamed rice',
          'white miso',
          'cucumber',
          'sesame seeds',
        ],
        description:
            'A glossy miso salmon bowl with warm rice, crisp cucumber, and a nutty sesame finish.',
        steps: [
          'Whisk miso with a little soy, honey, and sesame oil.',
          'Brush the salmon with glaze and roast until flaky.',
          'Build the bowl with rice and cucumber.',
          'Top with sesame seeds and extra glaze.',
        ],
        matchReason:
            'This balances quick prep with a strong protein base and clean umami flavour.',
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
          'harissa paste',
          'herbed yoghurt',
          'fresh coriander',
        ],
        description:
            'Crisp roasted cauliflower and chickpeas with smoky harissa, cooling yoghurt, and fresh herbs.',
        steps: [
          'Coat cauliflower and chickpeas with harissa.',
          'Roast until golden and lightly charred.',
          'Mix yoghurt with herbs and lemon.',
          'Serve warm with yoghurt and coriander.',
        ],
        matchReason:
            'A strong choice when you want something lighter, fast, and still flavour-driven.',
      ),
    ];
  }
}