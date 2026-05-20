class VaultFolder {
  final int folderId;
  final int vaultId;
  final String name;
  final DateTime createdAt;

  const VaultFolder({
    required this.folderId,
    required this.vaultId,
    required this.name,
    required this.createdAt,
  });

  factory VaultFolder.fromJson(Map<String, dynamic> json) {
    return VaultFolder(
      folderId: json['folder_id'],
      vaultId: json['vault_id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}