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

  //creates updated copy and keeps unchanged
  UserPreferences copyWith({
    List<DietaryDirective>? dietaryDirectives,
    List<String>? selectedAllergies,
    List<String>? availableAllergies,
    List<String>? dislikedIngredients,
    List<FlavourProfile>? flavourProfiles,
  }) {
    return UserPreferences(
      dietaryDirectives: dietaryDirectives ?? this.dietaryDirectives,
      selectedAllergies: selectedAllergies ?? this.selectedAllergies,
      availableAllergies: availableAllergies ?? this.availableAllergies,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      flavourProfiles: flavourProfiles ?? this.flavourProfiles,
    );
  }
}

//select dietary restrictions
class DietaryDirective {
  const DietaryDirective({
    required this.title,
    required this.subtitle,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final bool selected;

  //selected state
  DietaryDirective copyWith({
    String? title,
    String? subtitle,
    bool? selected,
  }) {
    return DietaryDirective(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      selected: selected ?? this.selected,
    );
  }
}

//dashboard with flavour profile
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

  //selected state
  FlavourProfile copyWith({
    String? label,
    String? description,
    String? iconKey,
    bool? selected,
  }) {
    return FlavourProfile(
      label: label ?? this.label,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      selected: selected ?? this.selected,
    );
  }
}