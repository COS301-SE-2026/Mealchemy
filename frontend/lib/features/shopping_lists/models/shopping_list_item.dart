class ShoppingListItem {
  const ShoppingListItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.checked = false,
  });

  final String id;
  final String name;
  final String quantity;
  final String category;
  final bool checked;

  ShoppingListItem copyWith({
    String? id,
    String? name,
    String? quantity,
    String? category,
    bool? checked,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      checked: checked ?? this.checked,
    );
  }
}