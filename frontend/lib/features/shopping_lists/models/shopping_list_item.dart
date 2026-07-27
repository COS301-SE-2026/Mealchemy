class ShoppingListItem {
  const ShoppingListItem({
    required this.id,
    this.itemId,
    this.shoppingListId,
    this.ingId,
    required this.name,
    required this.quantity,
    required this.category,
    this.unit,
    this.checked = false,
  });

  //id used by existing widgets/routes/tests
  final String id;

  //backend ids used for API calls
  final int? itemId;
  final int? shoppingListId;
  final int? ingId;

  final String name;

  //display quantity
  final String quantity;

  //backend category can be null for manually typed items
  final String category;

  //raw unit from backend
  final String? unit;

  //frontend checked maps to backend purchased
  final bool checked;

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    final itemId = _readInt(json['item_id']);
    final quantity = _formatQuantity(json['quantity'], json['unit']);

    return ShoppingListItem(
      id: itemId?.toString() ?? json['name']?.toString() ?? '',
      itemId: itemId,
      shoppingListId: _readInt(json['shopping_list_id']),
      ingId: _readInt(json['ing_id']),
      name: json['name']?.toString() ?? 'Unknown item',
      quantity: quantity,
      category: json['category']?.toString().toUpperCase() ?? 'MANUAL',
      unit: json['unit']?.toString(),
      checked: json['purchased'] == true,
    );
  }

  ShoppingListItem copyWith({
    String? id,
    int? itemId,
    int? shoppingListId,
    int? ingId,
    String? name,
    String? quantity,
    String? category,
    String? unit,
    bool? checked,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      ingId: ingId ?? this.ingId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      checked: checked ?? this.checked,
    );
  }
}

//backend ids arrive as numbers or strings
int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

String _formatQuantity(dynamic quantityValue, dynamic unitValue) {
  final quantity = _cleanNumber(quantityValue);
  final unit = unitValue?.toString() ?? '';

  if (quantity.isEmpty && unit.isEmpty) return '-';
  if (quantity.isEmpty) return unit;
  if (unit.isEmpty) return quantity;

  return '$quantity $unit';
}

String _cleanNumber(dynamic value) {
  if (value == null) return '';

  final raw = value.toString();
  final number = num.tryParse(raw);

  if (number == null) return raw;
  if (number % 1 == 0) return number.toInt().toString();

  return raw;
}
