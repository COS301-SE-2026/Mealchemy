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
import '../models/complete_shop_result.dart';

const List<String> _shoppingItemUnitOptions = [
  'g',
  'kg',
  'ml',
  'L',
  'cups',
  'tbsp',
  'tsp',
  'oz',
  'pcs',
];

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
            onUpdateItem: ({
              required itemId,
              required quantity,
              required unit,
            }) async {
              await ref
                  .read(shoppingListsProvider.notifier)
                  .updateShoppingListItem(
                    listId: list.id,
                    itemId: itemId,
                    quantity: quantity,
                    unit: unit,
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
            onDeleteList: () async {
              await ref
                  .read(shoppingListsProvider.notifier)
                  .deleteShoppingList(list.id);
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
    required this.onUpdateItem,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onCompleteShop,
    required this.onDeleteSelected,
    required this.onDeleteList,
  });

  final ShoppingList list;
  final Future<void> Function(String itemId) onToggleItem;
  final Future<void> Function({
    required String itemId,
    required String quantity,
    required String unit,
  }) onUpdateItem;
  final Future<void> Function() onSelectAll;
  final Future<void> Function() onDeselectAll;
  final Future<void> Function() onDeleteSelected;
  final Future<void> Function() onDeleteList;

  final Future<CompleteShopResult?> Function() onCompleteShop;

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
              ..._buildItemSections(context, groupedItems),
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

                final addedCount = result?.addedToPantryCount ?? checkedCount;

                final skippedItems = result?.skippedManualItems ?? <String>[];

                final skippedText = skippedItems.isEmpty
                    ? ''
                    : ' ${skippedItems.length} manual item skipped.';

                final message = addedCount == 1
                    ? '1 item sent to pantry.$skippedText'
                    : '$addedCount items sent to pantry.$skippedText';

                _showSnackBar(context, message);

                if (result?.canDeleteShoppingList != true) return;

                final shouldDelete = await _showDeleteEmptyShoppingListDialog(
                  context: context,
                  listName: list.title,
                );

                if (!context.mounted || !shouldDelete) return;

                try {
                  await onDeleteList();

                  if (!context.mounted) return;
                  context.go(AppRoutes.shoppingLists);
                } catch (_) {
                  if (!context.mounted) return;

                  _showSnackBar(
                    context,
                    'Could not delete the shopping list. Try again.',
                  );
                }
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
    BuildContext context,
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
            onEdit: () => _showEditShoppingListItemDialog(
              context: context,
              item: item,
              onSave: ({
                required quantity,
                required unit,
              }) {
                return onUpdateItem(
                  itemId: item.id,
                  quantity: quantity,
                  unit: unit,
                );
              },
            ),
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

Future<void> _showEditShoppingListItemDialog({
  required BuildContext context,
  required ShoppingListItem item,
  required Future<void> Function({
    required String quantity,
    required String unit,
  }) onSave,
}) async {
  final editableValues = _editableQuantityAndUnit(item);
  final quantityController = TextEditingController(
    text: editableValues.quantity,
  );

  var selectedUnit = editableValues.unit;
  var quantityError = false;
  var unitError = false;
  var isSaving = false;
  String? saveError;

  final availableUnits = <String>{
    ..._shoppingItemUnitOptions,
    if (selectedUnit != null && selectedUnit.isNotEmpty) selectedUnit,
  }.toList();

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> saveChanges() async {
            final quantity = quantityController.text.trim();
            final parsedQuantity = num.tryParse(quantity);
            final unit = selectedUnit?.trim() ?? '';

            final hasValidQuantity =
                parsedQuantity != null && parsedQuantity > 0;
            final hasUnit = unit.isNotEmpty;

            if (!hasValidQuantity || !hasUnit) {
              setDialogState(() {
                quantityError = !hasValidQuantity;
                unitError = !hasUnit;
                saveError = null;
              });
              return;
            }

            setDialogState(() {
              isSaving = true;
              saveError = null;
            });

            try {
              await onSave(
                quantity: quantity,
                unit: unit,
              );

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(true);
              }
            } catch (_) {
              if (!dialogContext.mounted) return;

              setDialogState(() {
                isSaving = false;
                saveError = 'Could not update the item. Try again.';
              });
            }
          }

          return AlertDialog(
            backgroundColor: AppColors.bgCream,
            title: Text(
              'Edit Shopping List Item',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    errorText: quantityError
                        ? 'Enter a quantity greater than zero.'
                        : null,
                  ),
                  onChanged: (_) {
                    if (!quantityError) return;
                    setDialogState(() => quantityError = false);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedUnit,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    errorText: unitError ? 'Unit is required.' : null,
                  ),
                  items: availableUnits.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedUnit = value;
                      unitError = false;
                    });
                  },
                ),
                if (saveError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      saveError!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving
                    ? null
                    : () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isSaving ? null : saveChanges,
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    quantityController.dispose();
  });

  if (saved != true || !context.mounted) return;

  _showSnackBar(
    context,
    '${item.name} updated.',
  );
}

({String quantity, String? unit}) _editableQuantityAndUnit(
  ShoppingListItem item,
) {
  final rawQuantity = item.quantity.trim();
  final storedUnit = item.unit?.trim();

  if (storedUnit != null && storedUnit.isNotEmpty) {
    final quantityWithoutUnit = rawQuantity.endsWith(storedUnit)
        ? rawQuantity
            .substring(0, rawQuantity.length - storedUnit.length)
            .trim()
        : rawQuantity;

    return (
      quantity: quantityWithoutUnit,
      unit: storedUnit,
    );
  }

  //older mock fixtures store quantity and unit together
  final match = RegExp(
    r'^([0-9]+(?:\.[0-9]+)?)\s*(.*)$',
  ).firstMatch(rawQuantity);

  if (match == null) {
    return (
      quantity: rawQuantity == '-' ? '' : rawQuantity,
      unit: null,
    );
  }

  final parsedUnit = match.group(2)?.trim() ?? '';

  return (
    quantity: match.group(1) ?? '',
    unit: parsedUnit.isEmpty ? null : parsedUnit,
  );
}

Future<bool> _showDeleteEmptyShoppingListDialog({
  required BuildContext context,
  required String listName,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.bgCream,
        title: Text(
          'Shopping List Empty',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
          ),
        ),
        content: Text(
          'All purchased items have been processed. '
          'Would you like to delete "$listName"?',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep List'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete List'),
          ),
        ],
      );
    },
  );

  return shouldDelete ?? false;
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
