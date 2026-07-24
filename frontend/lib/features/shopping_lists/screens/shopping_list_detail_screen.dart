import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/shopping_bottom_action_bar.dart';
import '../widgets/shopping_item_row.dart';
import '../widgets/shopping_section_header.dart';
import '../../../core/routes/app_routes.dart';

//detail screen for one shopping list
class ShoppingListDetailScreen extends ConsumerWidget {
  const ShoppingListDetailScreen({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists = ref.watch(shoppingListsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: shoppingLists.when(
        data: (state) {
          final list = state.getListById(listId);

          if (list == null) {
            return Center(
              child: Text(
                'Shopping list not found.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            );
          }

          return _ShoppingListDetailContent(
            list: list,
            onToggleItem: (itemId) async {
              await ref.read(shoppingListsProvider.notifier).toggleItemChecked(
                    listId: list.id,
                    itemId: itemId,
                  );
            },
            onAddItem: ({
              required name,
              required quantity,
              required category,
            }) async {
              await ref.read(shoppingListsProvider.notifier).addItemToList(
                    listId: list.id,
                    name: name,
                    quantity: quantity,
                    category: category,
                  );
            },
            onCompleteShop: () async {
              return ref
                  .read(shoppingListsProvider.notifier)
                  .completeShop(list.id);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (_, __) => Center(
          child: Text(
            'Unable to load shopping list.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

//loaded content for shopping list detail screen
class _ShoppingListDetailContent extends StatelessWidget {
  const _ShoppingListDetailContent({
    required this.list,
    required this.onToggleItem,
    required this.onAddItem,
    required this.onCompleteShop,
  });

  final ShoppingList list;
  final Future<void> Function(String itemId) onToggleItem;
  final Future<void> Function({
    required String name,
    required String quantity,
    required String category,
  }) onAddItem;
  final Future<Object?> Function() onCompleteShop;

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsByCategory(list.items);

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(28, 14, 28, 210),
            children: [
              _DetailTopBar(
                onBack: () => context.go(AppRoutes.shoppingLists),
              ),
              const SizedBox(height: 42),
              ShoppingSectionHeader(title: list.title),
              const SizedBox(height: 30),
              ..._buildItemSections(groupedItems),
            ],
          ),
          Positioned(
            left: 26,
            right: 26,
            bottom: 118,
            child: ShoppingBottomActionBar(
              onMicTap: () {},
              onAddTap: () => _showAddItemDialog(context),
              onFilterTap: () {},
            ),
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: 42,
            child: _UpdatePantryButton(
              onTap: () async {
                final checkedCount =
                    list.items.where((item) => item.checked).length;

                if (checkedCount == 0) {
                  _showSnackBar(
                    context,
                    'No checked items to update.',
                  );
                  return;
                }

                final result = await onCompleteShop();

                if (!context.mounted) return;

                final addedCount = result == null
                    ? checkedCount
                    : (result as dynamic).addedToPantryCount as int;

                final skippedItems = result == null
                    ? <String>[]
                    : (result as dynamic).skippedManualItems as List<String>;

                final skippedText = skippedItems.isEmpty
                    ? ''
                    : ' ${skippedItems.length} manual item skipped.';

                final message = addedCount == 1
                    ? '1 item sent to pantry.$skippedText'
                    : '$addedCount items sent to pantry.$skippedText';

                _showSnackBar(context, message);
              },
            ),
          ),
        ],
      ),
    );
  }

  //opens dialog to add temp mock shopping item
  Future<void> _showAddItemDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final categoryController = TextEditingController(text: 'Produce');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgLight,
          title: Text(
            'Add Item',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AddItemField(
                controller: nameController,
                label: 'Item name',
              ),
              const SizedBox(height: 12),
              _AddItemField(
                controller: quantityController,
                label: 'Quantity',
              ),
              const SizedBox(height: 12),
              _AddItemField(
                controller: categoryController,
                label: 'Category',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'quantity': quantityController.text,
                  'category': categoryController.text,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textDark,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    //dispose controllers after dialogue finished closing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameController.dispose();
      quantityController.dispose();
      categoryController.dispose();
    });

    if (result == null) return;

    await onAddItem(
      name: result['name'] ?? '',
      quantity: result['quantity'] ?? '',
      category: result['category'] ?? '',
    );
  }

  //groups shopping list items by category
  Map<String, List<ShoppingListItem>> _groupItemsByCategory(
    List<ShoppingListItem> items,
  ) {
    final groupedItems = <String, List<ShoppingListItem>>{};

    for (final item in items) {
      groupedItems.putIfAbsent(item.category, () => []);
      groupedItems[item.category]!.add(item);
    }

    return groupedItems;
  }

  //builds category headers and item rows
  List<Widget> _buildItemSections(
    Map<String, List<ShoppingListItem>> groupedItems,
  ) {
    final widgets = <Widget>[];

    for (final entry in groupedItems.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            entry.key,
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ),
      );

      for (final item in entry.value) {
        widgets.add(
          ShoppingItemRow(
            item: item,
            onChanged: (_) async => onToggleItem(item.id),
          ),
        );
      }

      widgets.add(const SizedBox(height: 26));
    }

    return widgets;
  }
}

//top row for back button, page title, and more menu
class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.primary,
            size: 30,
          ),
        ),
        Expanded(
          child: Text(
            'All Items',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.more_vert,
            color: AppColors.tertiaryMuted,
          ),
        ),
      ],
    );
  }
}

//button for sending checked items back to pantry
class _UpdatePantryButton extends StatelessWidget {
  const _UpdatePantryButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(10),
      elevation: 10,
      shadowColor: AppColors.primary.withValues(alpha: 0.28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.accent,
                size: 28,
              ),
              const SizedBox(width: 18),
              Text(
                'Update Pantry',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textDark,
                  fontFamily: AppTextStyles.heading2.fontFamily,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//text field used inside add item dialog
class _AddItemField extends StatelessWidget {
  const _AddItemField({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTextStyles.body.copyWith(
        color: AppColors.textLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.tertiaryMuted,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
