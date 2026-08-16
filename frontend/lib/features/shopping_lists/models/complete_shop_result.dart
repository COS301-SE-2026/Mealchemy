// Result returned after purchased shopping items are processed.
class CompleteShopResult {
  const CompleteShopResult({
    required this.addedToPantryCount,
    required this.skippedManualItems,
    required this.canDeleteShoppingList,
  });

  final int addedToPantryCount;
  final List<String> skippedManualItems;

  // True means the list is empty and the frontend may offer deletion.
  // The backend does not delete the list automatically.
  final bool canDeleteShoppingList;

  factory CompleteShopResult.fromJson(Map<String, dynamic> json) {
    return CompleteShopResult(
      addedToPantryCount: _readInt(json['added_to_pantry_count']) ?? 0,
      skippedManualItems: (json['skipped_manual_items'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      canDeleteShoppingList: json['can_delete_shopping_list'] == true,
    );
  }
}

int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
