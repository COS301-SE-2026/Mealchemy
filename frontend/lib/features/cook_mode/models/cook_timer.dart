class CookTimer {
  const CookTimer({
    required this.notificationId,
    required this.recipeId,
    required this.recipeTitle,
    required this.stepIndex,
    required this.stepNumber,
    required this.startedAt,
    required this.endsAt,
  });

  final int notificationId;
  final int recipeId;
  final String recipeTitle;
  final int stepIndex;
  final int stepNumber;
  final DateTime startedAt;
  final DateTime endsAt;

  String get label => '$recipeTitle, step $stepNumber';

  Duration remainingAt(DateTime now) {
    final remaining = endsAt.difference(now.toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool isFinishedAt(DateTime now) => !endsAt.isAfter(now.toUtc());

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'recipeId': recipeId,
        'recipeTitle': recipeTitle,
        'stepIndex': stepIndex,
        'stepNumber': stepNumber,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'endsAt': endsAt.toUtc().toIso8601String(),
      };

  factory CookTimer.fromJson(Map<String, dynamic> json) {
    return CookTimer(
      notificationId: json['notificationId'] as int,
      recipeId: json['recipeId'] as int,
      recipeTitle: json['recipeTitle'] as String,
      stepIndex: json['stepIndex'] as int,
      stepNumber: json['stepNumber'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String).toUtc(),
      endsAt: DateTime.parse(json['endsAt'] as String).toUtc(),
    );
  }
}

String formatCookDuration(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 24 * 60 * 60);
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  if (hours > 0) {
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }
  if (minutes > 0) {
    return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
  }
  return '${seconds}s';
}
