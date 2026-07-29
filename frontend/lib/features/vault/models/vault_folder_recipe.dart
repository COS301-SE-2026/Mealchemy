class VaultFolderRecipe {
  final int id;
  final int folderId;
  final int recipeId;
  final DateTime addedAt;
  final int? addedByUserId;

  VaultFolderRecipe({
    required this.id,
    required this.folderId,
    required this.recipeId,
    required this.addedAt,
    this.addedByUserId,
  });

  factory VaultFolderRecipe.fromJson(Map<String, dynamic> json) {
    return VaultFolderRecipe(
      id: json['id'] as int,
      folderId: json['folderId'] as int,
      recipeId: json['recipeId'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
      addedByUserId: json['addedByUserId'] as int?,
    );
  }
}
