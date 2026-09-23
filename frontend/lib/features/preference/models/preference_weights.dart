class PreferenceWeights {
  const PreferenceWeights({
    required this.pantryMatch,
    required this.cuisine,
    required this.nutrition,
    required this.freshness,
    required this.novelty,
  });

  final double pantryMatch;
  final double cuisine;
  final double nutrition;
  final double freshness;
  final double novelty;
  static const defaults = PreferenceWeights(
    pantryMatch: 0.40,
    cuisine: 0.25,
    nutrition: 0.10,
    freshness: 0.15,
    novelty: 0.10,
  );

  double get total => pantryMatch + cuisine + nutrition + freshness + novelty;
  double shareOf(double value) => total == 0 ? 0 : value / total;

  // The engine stores these as five weights that sum to 1.0 so scale before saving.
  PreferenceWeights normalized() {
    final sum = total;
    if (sum == 0) return defaults;
    return PreferenceWeights(
      pantryMatch: pantryMatch / sum,
      cuisine: cuisine / sum,
      nutrition: nutrition / sum,
      freshness: freshness / sum,
      novelty: novelty / sum,
    );
  }

  PreferenceWeights copyWith({
    double? pantryMatch,
    double? cuisine,
    double? nutrition,
    double? freshness,
    double? novelty,
  }) {
    return PreferenceWeights(
      pantryMatch: pantryMatch ?? this.pantryMatch,
      cuisine: cuisine ?? this.cuisine,
      nutrition: nutrition ?? this.nutrition,
      freshness: freshness ?? this.freshness,
      novelty: novelty ?? this.novelty,
    );
  }

  factory PreferenceWeights.fromJson(Map<String, dynamic> json) {
    double read(String key) => (json[key] as num).toDouble();
    return PreferenceWeights(
      pantryMatch: read('pantry_match'),
      cuisine: read('cuisine'),
      nutrition: read('nutrition'),
      freshness: read('freshness'),
      novelty: read('novelty'),
    );
  }

  Map<String, dynamic> toJson() => {
        'pantry_match': pantryMatch,
        'cuisine': cuisine,
        'nutrition': nutrition,
        'freshness': freshness,
        'novelty': novelty,
      };
}
