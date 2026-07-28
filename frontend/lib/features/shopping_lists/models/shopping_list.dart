import 'shopping_list_item.dart';

class ShoppingList {
  const ShoppingList({
    required this.id,
    this.shoppingListId,
    this.userId,
    required this.title,
    required this.subtitle,
    required this.section,
    required this.iconType,
    required this.items,
    this.status,
    this.createdAt,
    this.imageUrl,
    this.favourite = false,
  });

  //id used by existing routes/widgets
  final String id;

  //backend ids etc used for API calls
  final int? shoppingListId;
  final int? userId;
  final String? status;
  final DateTime? createdAt;

  final String title;
  final String subtitle;
  final String section;
  final String iconType;
  final String? imageUrl;
  final bool favourite;
  final List<ShoppingListItem> items;

  int get itemCount => items.length;

  //returns subtitle text from latest item count
  String get displaySubtitle {
    if (section == 'FROM YOUR RECIPES') {
      return '$itemCount items · Ready to shop';
    }

    return '$itemCount items added by you';
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    final shoppingListId = _readInt(json['shopping_list_id']);
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson
        .map((item) => ShoppingListItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return ShoppingList(
      id: shoppingListId?.toString() ?? json['name']?.toString() ?? '',
      shoppingListId: shoppingListId,
      userId: _readInt(json['user_id']),
      title: json['name']?.toString() ?? 'Untitled list',
      subtitle: '${items.length} items',
      section: 'OTHER LISTS',
      iconType: 'list',
      status: json['status']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      items: items,
    );
  }

  ShoppingList copyWith({
    String? id,
    int? shoppingListId,
    int? userId,
    String? title,
    String? subtitle,
    String? section,
    String? iconType,
    String? status,
    DateTime? createdAt,
    String? imageUrl,
    bool? favourite,
    List<ShoppingListItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      section: section ?? this.section,
      iconType: iconType ?? this.iconType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      favourite: favourite ?? this.favourite,
      items: items ?? this.items,
    );
  }
}

//kept local
int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
