import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shopping_lists/models/shopping_list.dart';
import '../../shopping_lists/providers/shopping_list_provider.dart';

//most recently created shopping list, or null when there are none
final newListProvider = Provider<ShoppingList?>((ref) {
  final listsAsync = ref.watch(shoppingListsProvider);

  return listsAsync.maybeWhen(
    data: (state) {
      if (state.lists.isEmpty) return null;

      final sorted = [...state.lists]..sort((a, b) {
          final aDate = a.createdAt;
          final bDate = b.createdAt;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });

      return sorted.first;
    },
    orElse: () => null,
  );
});