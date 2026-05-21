class VaultFolder {
  final int folderId;
  final int vaultId;
  final String name;
  final DateTime createdAt;

  VaultFolder({
    required this.folderId,
    required this.vaultId,
    required this.name,
    required this.createdAt,
  });

  factory VaultFolder.fromJson(Map<String, dynamic> json) {
    return VaultFolder(
      folderId: json['folderId'] as int,
      vaultId: json['vaultId'] as int,
      name: json['folderName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}