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
import '../../pantry/providers/pantry_provider.dart';

//detail screen for one shopping list
class ShoppingListDetailScreen extends ConsumerStatefulWidget {
  const ShoppingListDetailScreen({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  ConsumerState<ShoppingListDetailScreen> createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState
    extends ConsumerState<ShoppingListDetailScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(_loadShoppingListDetail);
  }

  @override
  void didUpdateWidget(covariant ShoppingListDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.listId != widget.listId) {
      Future.microtask(_loadShoppingListDetail);
    }
  }

  Future<void> _loadShoppingListDetail() async {
    await ref.read(shoppingListsProvider.future);

    await ref
        .read(shoppingListsProvider.notifier)
        .loadShoppingListDetail(widget.listId);
  }

  @override
  Widget build(BuildContext context) {
    final shoppingLists = ref.watch(shoppingListsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: shoppingLists.when(
        data: (state) {
          final list = state.getListById(widget.listId);

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
            onSelectAll: () async {
              await ref
                  .read(shoppingListsProvider.notifier)
                  .selectAllItems(list.id);
            },
            onDeselectAll: () async {
              await ref
                  .read(shoppingListsProvider.notifier)
                  .deselectAllItems(list.id);
            },
            onDeleteSelected: () async {
              await ref
                  .read(shoppingListsProvider.notifier)
                  .deleteSelectedItems(list.id);
            },
            onCompleteShop: () async {
              final result = await ref
                  .read(shoppingListsProvider.notifier)
                  .completeShop(list.id);

              //complete-shop endpoint changed pantry data outside the pantry feature
              //recreate the repository to clear internal ingredient cache, then reloadthe pantry state from the backend
              ref.invalidate(pantryRepositoryProvider);
              ref.invalidate(pantryStateProvider);

              return result;
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
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onCompleteShop,
    required this.onDeleteSelected,
  });

  final ShoppingList list;
  final Future<void> Function(String itemId) onToggleItem;
  final Future<void> Function() onSelectAll;
  final Future<void> Function() onDeselectAll;
  final Future<void> Function() onDeleteSelected;

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
                onDeleteSelected: () async {
                  final selectedCount =
                      list.items.where((item) => item.checked).length;

                  if (selectedCount == 0) {
                    _showSnackBar(
                      context,
                      'No selected items to delete.',
                    );
                    return;
                  }

                  await onDeleteSelected();

                  if (!context.mounted) return;

                  final message = selectedCount == 1
                      ? '1 selected item deleted.'
                      : '$selectedCount selected items deleted.';

                  _showSnackBar(context, message);
                },
              ),
              const SizedBox(height: 42),
              ShoppingSectionHeader(title: list.title),
              const SizedBox(height: 30),
              _BulkSelectionControls(
                onSelectAll: onSelectAll,
                onDeselectAll: onDeselectAll,
              ),
              const SizedBox(height: 22),
              ..._buildItemSections(groupedItems),
            ],
          ),
          Positioned(
            left: 26,
            right: 26,
            bottom: 118,
            child: ShoppingBottomActionBar(
              onMicTap: () {},
              onAddTap: () {
                context.push('/shopping-lists/${list.id}/add-item');
              },
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
    required this.onDeleteSelected,
  });

  final VoidCallback onBack;
  final Future<void> Function() onDeleteSelected;

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
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: AppColors.tertiaryMuted,
          ),
          color: AppColors.bgLight,
          onSelected: (value) async {
            if (value == 'delete-selected') {
              await onDeleteSelected();
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'delete-selected',
                child: Text(
                  'Delete selected',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
}

class _BulkSelectionControls extends StatelessWidget {
  const _BulkSelectionControls({
    required this.onSelectAll,
    required this.onDeselectAll,
  });

  final Future<void> Function() onSelectAll;
  final Future<void> Function() onDeselectAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BulkSelectionButton(
          icon: Icons.done_all,
          label: 'Select all',
          onPressed: onSelectAll,
        ),
        const SizedBox(width: 10),
        _BulkSelectionButton(
          icon: Icons.remove_done,
          label: 'Deselect',
          onPressed: onDeselectAll,
        ),
      ],
    );
  }
}

class _BulkSelectionButton extends StatelessWidget {
  const _BulkSelectionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () async {
          await onPressed();
        },
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.45),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
