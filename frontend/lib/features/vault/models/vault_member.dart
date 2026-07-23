class VaultMember {
  final int id;
  final int vaultId;
  final int userId;
  final DateTime joinedAt;
//will add a email feld later after backend chat 
  VaultMember({
    required this.id,
    required this.vaultId,
    required this.userId,
    required this.joinedAt,
  });

  factory VaultMember.fromJson(Map<String, dynamic> json) {
    return VaultMember(
      id: json['id'] as int,
      vaultId: json['vaultId'] as int,
      userId: json['userId'] as int,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}