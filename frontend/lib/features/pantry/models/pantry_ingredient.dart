import '../widgets/pantry_item_card.dart';

//data for one pantry ingredient row
class PantryIngredient {
  const PantryIngredient({
    this.pIngredientId,
    this.ingId,
    required this.name,
    required this.details,
    required this.category,
    required this.status,
    this.quantity,
    this.unit,
  });

  //backend pantry row id, used for PUT/DELETE calls
  final int? pIngredientId;

  //ingredient catalogue id, (adding/updating pantry items)
  final int? ingId;

  final String name;
  final String details;
  final String category;
  final PantryItemStatus status;

  //keeping these separate makes API updates easier than unpacking details text
  final String? quantity;
  final String? unit;

  //creates updated ingredient without changing original
  PantryIngredient copyWith({
    int? pIngredientId,
    int? ingId,
    String? name,
    String? details,
    String? category,
    PantryItemStatus? status,
    String? quantity,
    String? unit,
  }) {
    return PantryIngredient(
      pIngredientId: pIngredientId ?? this.pIngredientId,
      ingId: ingId ?? this.ingId,
      name: name ?? this.name,
      details: details ?? this.details,
      category: category ?? this.category,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}
