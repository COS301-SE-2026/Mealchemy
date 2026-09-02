class UserPreferences {
  const UserPreferences({
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.dislikedIngredients = const [],
    this.flavourProfile = const [],
    this.nutritionalGoals = const [],
  });

  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final List<String> dislikedIngredients;
  final List<String> flavourProfile;
  final List<String> nutritionalGoals;

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    List<String> read(String key) =>
        (json[key] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList();

    return UserPreferences(
      dietaryRestrictions: read('dietaryRestrictions'),
      allergies: read('allergies'),
      dislikedIngredients: read('dislikedIngredients'),
      flavourProfile: read('flavourProfile'),
      nutritionalGoals: read('nutritionalGoals'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dietaryRestrictions': dietaryRestrictions,
      'allergies': allergies,
      'dislikedIngredients': dislikedIngredients,
      'flavourProfile': flavourProfile,
      'nutritionalGoals': nutritionalGoals,
    };
  }

  UserPreferences copyWith({
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    List<String>? dislikedIngredients,
    List<String>? flavourProfile,
    List<String>? nutritionalGoals,
  }) {
    return UserPreferences(
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      flavourProfile: flavourProfile ?? this.flavourProfile,
      nutritionalGoals: nutritionalGoals ?? this.nutritionalGoals,
    );
  }
}