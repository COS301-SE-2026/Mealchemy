// The five signal scores behind a recommendation's ranking.
class SignalScores {
  final double pantryMatch;
  final double cuisine;
  final double nutrition;
  final double freshness;
  final double novelty;

  const SignalScores({
    required this.pantryMatch,
    required this.cuisine,
    required this.nutrition,
    required this.freshness,
    required this.novelty,
  });

  factory SignalScores.fromJson(Map<String, dynamic> json) {
    double read(String key) => (json[key] as num?)?.toDouble() ?? 0.0;
    return SignalScores(
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