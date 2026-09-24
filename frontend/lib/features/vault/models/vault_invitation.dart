enum VaultInvitationStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  declined('DECLINED'),
  cancelled('CANCELLED'),
  expired('EXPIRED');

  const VaultInvitationStatus(this.apiValue);

  final String apiValue;

  static VaultInvitationStatus fromJson(Object? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }

    throw FormatException('Unknown vault invitation status: $value');
  }
}

class VaultInvitation {
  const VaultInvitation({
    required this.invitationId,
    required this.vaultId,
    required this.vaultName,
    required this.invitedEmail,
    required this.invitedByEmail,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
  });

  final int invitationId;
  final int vaultId;
  final String vaultName;
  final String invitedEmail;
  final String invitedByEmail;
  final VaultInvitationStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;

  // The backend does not currently enforce expiresAt.
  // Only the returned status determines whether an invite is pending.
  bool get isPending => status == VaultInvitationStatus.pending;

  factory VaultInvitation.fromJson(Map<String, dynamic> json) {
    return VaultInvitation(
      invitationId: json['invitationId'] as int,
      vaultId: json['vaultId'] as int,
      vaultName: json['vaultName'] as String,
      invitedEmail: json['invitedEmail'] as String,
      invitedByEmail: json['invitedByEmail'] as String,
      status: VaultInvitationStatus.fromJson(json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
    );
  }

  VaultInvitation withResponse(
    VaultInvitationStatus status,
    DateTime respondedAt,
  ) {
    return VaultInvitation(
      invitationId: invitationId,
      vaultId: vaultId,
      vaultName: vaultName,
      invitedEmail: invitedEmail,
      invitedByEmail: invitedByEmail,
      status: status,
      createdAt: createdAt,
      expiresAt: expiresAt,
      respondedAt: respondedAt,
    );
  }
}
