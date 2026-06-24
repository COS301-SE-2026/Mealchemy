import 'shopping_list_item.dart';

class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.section,
    required this.iconType,
    required this.items,
    this.imageUrl,
    this.favourite = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String section;
  final String iconType;
  final String? imageUrl;
  final bool favourite;
  final List<ShoppingListItem> items;

  int get itemCount => items.length;

  ShoppingList copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? section,
    String? iconType,
    String? imageUrl,
    bool? favourite,
    List<ShoppingListItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      section: section ?? this.section,
      iconType: iconType ?? this.iconType,
      imageUrl: imageUrl ?? this.imageUrl,
      favourite: favourite ?? this.favourite,
      items: items ?? this.items,
    );
  }
}