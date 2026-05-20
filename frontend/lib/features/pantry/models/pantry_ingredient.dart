import '../widgets/pantry_item_card.dart';

//data for one pantry ingredient row
class PantryIngredient {
  const PantryIngredient({
    required this.name,
    required this.details,
    required this.category,
    required this.status,
  });

  final String name;
  final String details;
  final String category;
  final PantryItemStatus status;

  //creates updated ingredient without changing original
  PantryIngredient copyWith({
    String? name,
    String? details,
    String? category,
    PantryItemStatus? status,
  }) {
    return PantryIngredient(
      name: name ?? this.name,
      details: details ?? this.details,
      category: category ?? this.category,
      status: status ?? this.status,
    );
  }
}