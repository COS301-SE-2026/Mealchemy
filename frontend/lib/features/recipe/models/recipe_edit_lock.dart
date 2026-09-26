class RecipeEditLock {
  const RecipeEditLock({
    required this.recipeId,
    required this.lockedByUserId,
    required this.lockedByEmail,
    required this.acquiredAt,
    required this.expiresAt,
  });

  final int recipeId;
  final int lockedByUserId;
  final String lockedByEmail;
  final DateTime acquiredAt;
  final DateTime expiresAt;

  bool isHeldBy(int userId) => lockedByUserId == userId;

  bool isExpiredAt(DateTime time) => !expiresAt.isAfter(time);

  factory RecipeEditLock.fromJson(Map<String, dynamic> json) {
    final recipeId = json['recipeId'];
    final userId = json['lockedByUserId'];
    final email = json['lockedByEmail'];

    if (recipeId is! int || recipeId <= 0) {
      throw const FormatException('Invalid lock recipe ID.');
    }

    if (userId is! int || userId <= 0) {
      throw const FormatException('Invalid lock holder ID.');
    }

    if (email is! String || email.trim().isEmpty) {
      throw const FormatException('Invalid lock holder email.');
    }

    final acquiredAt = _parseTimestamp(json['acquiredAt']);
    final expiresAt = _parseTimestamp(json['expiresAt']);

    if (!expiresAt.isAfter(acquiredAt)) {
      throw const FormatException('Invalid lock expiry.');
    }

    return RecipeEditLock(
      recipeId: recipeId,
      lockedByUserId: userId,
      lockedByEmail: email,
      acquiredAt: acquiredAt,
      expiresAt: expiresAt,
    );
  }

  static DateTime _parseTimestamp(Object? value) {
    if (value is! String || !RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(value)) {
      throw const FormatException('Lock timestamps must include a timezone.');
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw const FormatException('Invalid lock timestamp.');
    }

    return parsed.toUtc();
  }
}
