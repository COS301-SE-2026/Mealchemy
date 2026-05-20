import '../models/user_preferences.dart';
import 'preference_repository.dart';

//mock data (while API not connected)
class MockPreferenceRepository implements PreferenceRepository {
  @override
  Future<UserPreferences> getUserPreferences() async {
    return const UserPreferences(
      dietaryDirectives: [
        DietaryDirective(
          title: 'PLANT-BASED / VEGAN',
          subtitle: 'Exclusively botanical-led cuisine.',
        ),
        DietaryDirective(
          title: 'CELIAC FRIENDLY / GLUTEN-FREE',
          subtitle: 'Rigorous gluten-free adherence.',
          selected: true,
        ),
        DietaryDirective(
          title: 'DAIRY FREE',
          subtitle: 'Lactose and casein-free alternatives.',
        ),
        DietaryDirective(
          title: 'CARB CONSCIOUS / KETO',
          subtitle: 'High protein and healthy fats focus.',
        ),
      ],
      selectedAllergies: ['PEANUTS', 'SHELLFISH'],
      availableAllergies: ['TREE NUTS', 'SOY', 'EGGS'],
      dislikedIngredients: ['CILANTRO', 'CAPERS', 'BLUE CHEESE'],
      flavourProfiles: [
        FlavourProfile(
          label: 'Mediterranean',
          description:
              'Bright herbs, olive oil, citrus, grains, and fresh vegetables.',
          iconKey: 'mediterranean',
          selected: true,
        ),
        FlavourProfile(
          label: 'Asian Fusion',
          description:
              'Soy, ginger, chilli, sesame, rice bowls, noodles, and umami-rich sauces.',
          iconKey: 'asian',
        ),
        FlavourProfile(
          label: 'Comfort Classics',
          description:
              'Warm, familiar meals with hearty textures and simple pantry staples.',
          iconKey: 'comfort',
        ),
        FlavourProfile(
          label: 'Fresh & Light',
          description:
              'Lean proteins, crisp produce, lighter sauces, and balanced portions.',
          iconKey: 'fresh',
        ),
      ],
    );
  }
}