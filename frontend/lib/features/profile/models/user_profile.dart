enum PreferredUnit {
  metric('METRIC', 'Metric'),
  imperial('IMPERIAL', 'Imperial');

  const PreferredUnit(this.value, this.label);

  final String value;
  final String label;

  static PreferredUnit fromValue(String? value) {
    return PreferredUnit.values.firstWhere(
      (u) => u.value == value,
      orElse: () => PreferredUnit.metric,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.preferredUnit,
    required this.equipment,
    this.email = '',
    this.avatarUrl,
    this.updatedAt,
  });

  final String displayName;
  final String? avatarUrl;
  final PreferredUnit preferredUnit;
  final List<String> equipment;
  final String email;
  final DateTime? updatedAt;

  String get initials {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      preferredUnit: PreferredUnit.fromValue(json['preferred_unit'] as String?),
      equipment: (json['equipment'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'preferred_unit': preferredUnit.value,
      'equipment': equipment,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? Function()? avatarUrl,
    PreferredUnit? preferredUnit,
    List<String>? equipment,
    String? email,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      equipment: equipment ?? this.equipment,
      email: email ?? this.email,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
