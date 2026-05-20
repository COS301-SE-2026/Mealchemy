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
      folderId: json['folder_id'] as int,
      vaultId: json['vault_id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}