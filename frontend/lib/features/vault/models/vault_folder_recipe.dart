class VaultFolderRecipe {
  final int id;
  final int folderId;
  final int recipeId;
  final DateTime addedAt;

  VaultFolderRecipe({
    required this.id,
    required this.folderId,
    required this.recipeId,
    required this.addedAt,
  });

  factory VaultFolderRecipe.fromJson(Map<String, dynamic> json) {
    return VaultFolderRecipe(
      folderId: json['id'] as int,
      vaultId: json['folderId'] as int,
      name: json['recipeId'] as int,
      createdAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}