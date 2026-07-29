class VaultFolder {
  final int folderId;
  final int vaultId;
  final String folderName;
  final DateTime createdAt;

  VaultFolder({
    required this.folderId,
    required this.vaultId,
    required this.folderName,
    required this.createdAt,
  });

  factory VaultFolder.fromJson(Map<String, dynamic> json) {
    return VaultFolder(
      folderId: json['folderId'] as int,
      vaultId: json['vaultId'] as int,
      folderName: json['folderName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
