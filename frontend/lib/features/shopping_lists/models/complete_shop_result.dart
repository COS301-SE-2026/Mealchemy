//result returned after purchased shopping items moved into pantry
class CompleteShopResult {
  const CompleteShopResult({
    required this.addedToPantryCount,
    required this.skippedManualItems,
    required this.shoppingListDeleted,
  });

  final int addedToPantryCount;
  final List<String> skippedManualItems;
  final bool shoppingListDeleted;

  factory CompleteShopResult.fromJson(Map<String, dynamic> json) {
    return CompleteShopResult(
      addedToPantryCount: _readInt(json['added_to_pantry_count']) ?? 0,
      skippedManualItems: (json['skipped_manual_items'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      shoppingListDeleted: json['shopping_list_deleted'] == true,
    );
  }
}

//helper
int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
