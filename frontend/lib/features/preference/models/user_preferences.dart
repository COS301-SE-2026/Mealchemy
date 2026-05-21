//data used by preference profile
class UserPreferences {
  const UserPreferences({
    required this.dietaryDirectives,
    required this.selectedAllergies,
    required this.availableAllergies,
    required this.dislikedIngredients,
    required this.flavourProfiles,
  });

  final List<DietaryDirective> dietaryDirectives;
  final List<String> selectedAllergies;
  final List<String> availableAllergies;
  final List<String> dislikedIngredients;
  final List<FlavourProfile> flavourProfiles;
}

//user can select dietary restrictions etc
class DietaryDirective {
  const DietaryDirective({
    required this.title,
    required this.subtitle,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final bool selected;
}

//dashboard for flavour profile
class FlavourProfile {
  const FlavourProfile({
    required this.label,
    required this.description,
    required this.iconKey,
    this.selected = false,
  });

  final String label;
  final String description;
  final String iconKey;
  final bool selected;
}