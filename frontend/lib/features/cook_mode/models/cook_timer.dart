import 'dart:convert';

class CookTimer {
  const CookTimer({
    required this.notificationId,
    required this.recipeId,
    required this.recipeTitle,
    required this.stepIndex,
    required this.stepNumber,
    required this.startedAt,
    required this.endsAt,
    this.name,
    this.pausedAt,
  });

  final int notificationId;
  final int recipeId;
  final String recipeTitle;
  final int stepIndex;
  final int stepNumber;
  final DateTime startedAt;
  final DateTime endsAt;
  final String? name;
  final DateTime? pausedAt;

  bool get isPaused => pausedAt != null;

  String get label {
    final timerName = name;
    return timerName == null
        ? '$recipeTitle, step $stepNumber'
        : '$timerName, $recipeTitle, step $stepNumber';
  }

  Duration remainingAt(DateTime now) {
    final referenceTime = pausedAt ?? now.toUtc();
    final remaining = endsAt.difference(referenceTime);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool isFinishedAt(DateTime now) => remainingAt(now) == Duration.zero;

  CookTimer pauseAt(DateTime now) {
    final pauseTime = now.toUtc();
    if (isPaused || isFinishedAt(pauseTime)) return this;
    return _copyWith(pausedAt: pauseTime);
  }

  CookTimer resumeAt(DateTime now) {
    final pauseTime = pausedAt;
    if (pauseTime == null) return this;
    final resumeTime = now.toUtc();
    final pausedDuration = resumeTime.isAfter(pauseTime)
        ? resumeTime.difference(pauseTime)
        : Duration.zero;
    return _copyWith(
      startedAt: startedAt.add(pausedDuration),
      endsAt: endsAt.add(pausedDuration),
      clearPausedAt: true,
    );
  }

  CookTimer _copyWith({
    DateTime? startedAt,
    DateTime? endsAt,
    DateTime? pausedAt,
    bool clearPausedAt = false,
  }) {
    return CookTimer(
      notificationId: notificationId,
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      stepIndex: stepIndex,
      stepNumber: stepNumber,
      startedAt: startedAt ?? this.startedAt,
      endsAt: endsAt ?? this.endsAt,
      name: name,
      pausedAt: clearPausedAt ? null : pausedAt ?? this.pausedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'recipeId': recipeId,
        'recipeTitle': recipeTitle,
        'stepIndex': stepIndex,
        'stepNumber': stepNumber,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'endsAt': endsAt.toUtc().toIso8601String(),
        if (name != null) 'name': name,
        if (pausedAt != null) 'pausedAt': pausedAt!.toUtc().toIso8601String(),
      };

  factory CookTimer.fromJson(Map<String, dynamic> json) {
    final storedName = json['name'];
    final normalizedName = storedName is String ? storedName.trim() : '';
    final storedPausedAt = json['pausedAt'];
    return CookTimer(
      notificationId: json['notificationId'] as int,
      recipeId: json['recipeId'] as int,
      recipeTitle: json['recipeTitle'] as String,
      stepIndex: json['stepIndex'] as int,
      stepNumber: json['stepNumber'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String).toUtc(),
      endsAt: DateTime.parse(json['endsAt'] as String).toUtc(),
      name: normalizedName.isEmpty ? null : normalizedName,
      pausedAt: storedPausedAt is String
          ? DateTime.parse(storedPausedAt).toUtc()
          : null,
    );
  }
}

class CookTimerDestination {
  const CookTimerDestination({
    required this.recipeId,
    required this.stepIndex,
  });

  final int recipeId;
  final int stepIndex;

  String toPayload() => jsonEncode({
        'type': 'cook_timer',
        'recipeId': recipeId,
        'stepIndex': stepIndex,
      });

  static CookTimerDestination? fromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic> || decoded['type'] != 'cook_timer') {
        return null;
      }
      final recipeId = decoded['recipeId'];
      final stepIndex = decoded['stepIndex'];
      if (recipeId is! int ||
          recipeId <= 0 ||
          stepIndex is! int ||
          stepIndex < 0) {
        return null;
      }
      return CookTimerDestination(
        recipeId: recipeId,
        stepIndex: stepIndex,
      );
    } catch (_) {
      return null;
    }
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

String formatCookTimerClock(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 24 * 60 * 60);
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final paddedMinutes = minutes.toString().padLeft(2, '0');
  final paddedSeconds = seconds.toString().padLeft(2, '0');

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:$paddedMinutes:$paddedSeconds';
  }
  return '$paddedMinutes:$paddedSeconds';
}
