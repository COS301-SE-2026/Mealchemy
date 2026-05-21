class Vault {
  final int vaultId;
  final int? ownerId;
  final String vaultType;
  final String name;
  final DateTime createdAt;

  const Vault({
    required this.vaultId,
    this.ownerId,
    required this.vaultType,
    required this.name,
    required this.createdAt;
  });

  factory Vault.fromJson(Map<String, dynamic> json) {
    return Vault(
      vaultId: json['vaultId'],
      ownerId: json['ownerId'],
      vaultType: json['vaultType'],
      name: json['name'],
      createdAt: json['createdAt']
    );
  }
}