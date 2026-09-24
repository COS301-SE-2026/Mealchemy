enum VaultMemberRole {
  owner('OWNER'),
  editor('EDITOR'),
  viewer('VIEWER');

  const VaultMemberRole(this.apiValue);

  final String apiValue;

  static VaultMemberRole fromJson(Object? value) {
    for (final role in values) {
      if (role.apiValue == value) return role;
    }

    throw FormatException('Unknown vault member role: $value');
  }
}

class VaultMember {
  const VaultMember({
    required this.id,
    required this.vaultId,
    required this.userId,
    required this.email,
    required this.joinedAt,
    required this.role,
  });

  // The synthetic owner entry has no membership-row ID.
  final int? id;
  final int vaultId;
  final int userId;
  final String email;
  final DateTime joinedAt;
  final VaultMemberRole role;

  bool get isOwner => role == VaultMemberRole.owner;

  factory VaultMember.fromJson(Map<String, dynamic> json) {
    return VaultMember(
      id: json['id'] as int?,
      vaultId: json['vaultId'] as int,
      userId: json['userId'] as int,
      email: json['email'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      role: VaultMemberRole.fromJson(json['role']),
    );
  }

  VaultMember copyWithRole(VaultMemberRole role) {
    return VaultMember(
      id: id,
      vaultId: vaultId,
      userId: userId,
      email: email,
      joinedAt: joinedAt,
      role: role,
    );
  }
}
