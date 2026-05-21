class Vault {
  final int vaultId;
  final int? ownerId;
  final String vaultType;
  final String name;

  const Vault({
    required this.vaultId,
    this.ownerId,
    required this.vaultType,
    required this.name,
  });

  factory Vault.fromJson(Map<String, dynamic> json) {
    return Vault(
      vaultId: json['vault_id'],
      ownerId: json['owner_id'],
      vaultType: json['vault_type'],
      name: json['name'],
    );
  }
}