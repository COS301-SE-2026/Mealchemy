import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../../core/shared_widgets/Molecules/app_refresh.dart';
import '../../../core/shared_widgets/atoms/app_icon_button.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/shopping_list.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/shopping_list_row.dart';
import '../widgets/shopping_section_header.dart';
import '../../offline/data/offline_cache_store.dart';
import '../../offline/widgets/cache_freshness_label.dart';

//main overview screen
class ShoppingListsScreen extends ConsumerWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists = ref.watch(shoppingListsProvider);
    final isReadOnly = ref.watch(offlineReadOnlyProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      floatingActionButton: FloatingActionButton(
        onPressed: isReadOnly
            ? null
            : () => _showCreateListDialog(
                  context,
                  (name) async {
                    await ref
                        .read(shoppingListsProvider.notifier)
                        .createShoppingList(name: name);
                  },
                ),
        backgroundColor:
            isReadOnly ? AppColors.surfaceMuted : AppColors.primary,
        foregroundColor: AppColors.textDark,
        elevation: 8,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: AppRefresh(
          onRefresh: () =>
              ref.read(shoppingListsProvider.notifier).resetShoppingLists(),
          child: shoppingLists.when(
            data: (state) => _ShoppingListsContent(
              state: state,
              isReadOnly: isReadOnly,
              onSearchChanged: (query) {
                ref
                    .read(shoppingListsProvider.notifier)
                    .updateSearchQuery(query);
              },
              onUpdateListName: ({
                required listId,
                required name,
              }) async {
                await ref
                    .read(shoppingListsProvider.notifier)
                    .updateShoppingListName(
                      listId: listId,
                      name: name,
                    );
              },
              onDeleteList: (listId) async {
                await ref
                    .read(shoppingListsProvider.notifier)
                    .deleteShoppingList(listId);
              },
            ),
            loading: () => const _ScrollableCentre(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, __) => _ScrollableCentre(
              child: Text(
                'Unable to load shopping lists.',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Wraps a centred widget in a scroll view so pull-to-refresh still triggers
// on the loading and error states.
class _ScrollableCentre extends StatelessWidget {
  const _ScrollableCentre({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}

//loaded content for shopping lists overview screen
class _ShoppingListsContent extends ConsumerWidget {
  const _ShoppingListsContent({
    required this.state,
    required this.isReadOnly,
    required this.onSearchChanged,
    required this.onUpdateListName,
    required this.onDeleteList,
  });

  final ShoppingListsState state;
  final bool isReadOnly;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function({
    required String listId,
    required String name,
  }) onUpdateListName;
  final Future<void> Function(String listId) onDeleteList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchOpen = ref.watch(searchOpenProvider);

    final groupedLists = state.groupedFilteredLists;
    final listWidgets = state.filteredLists.isEmpty
        ? <Widget>[const _EmptySearchState()]
        : _buildSections(
            context: context,
            groupedLists: groupedLists,
            isReadOnly: isReadOnly,
            onUpdateListName: onUpdateListName,
            onDeleteList: onDeleteList,
          );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 96),
      children: [
        _ShoppingListsTitle(
          onSearchTap: () {
            ref.read(searchOpenProvider.notifier).state = !searchOpen;
          },
        ),
        if (searchOpen) ...[
          const SizedBox(height: 18),
          _SearchField(
            query: state.searchQuery,
            onChanged: onSearchChanged,
            onClose: () {
              onSearchChanged('');
              ref.read(searchOpenProvider.notifier).state = false;
            },
          ),
        ],
        const SizedBox(height: 6),
        const CacheFreshnessLabel(
          collection: CacheCollection.shoppingLists,
          scopeId: CacheScope.all,
        ),
        const SizedBox(height: 30),
        ShoppingSectionHeader(
          title: 'Lists',
          trailing: '${state.filteredLists.length} lists',
        ),
        const SizedBox(height: 34),
        ...listWidgets,
      ],
    );
  }

  //builds each grouped shopping list section
  List<Widget> _buildSections({
    required BuildContext context,
    required Map<String, List<ShoppingList>> groupedLists,
    required bool isReadOnly,
    required Future<void> Function({
      required String listId,
      required String name,
    }) onUpdateListName,
    required Future<void> Function(String listId) onDeleteList,
  }) {
    final widgets = <Widget>[];

    for (final entry in groupedLists.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
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

      for (final list in entry.value) {
        widgets.add(
          ShoppingListRow(
            list: list,
            mutationsEnabled: !isReadOnly,
            onTap: () {
              context.go('/shopping-lists/${list.id}');
            },
            onEditTap: () => _showEditListNameDialog(
              context: context,
              list: list,
              onUpdateListName: onUpdateListName,
            ),
            onMoreTap: () => _showListActionsMenu(
              context: context,
              list: list,
              onDeleteList: onDeleteList,
            ),
          ),
        );
      }

      widgets.add(const SizedBox(height: 18));
    }

    return widgets;
  }
}

//inline search field shown when the title search icon is toggled on
class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.query,
    required this.onChanged,
    required this.onClose,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: true,
      onChanged: widget.onChanged,
      style: AppTextStyles.body.copyWith(color: AppColors.textLight),
      decoration: InputDecoration(
        hintText: 'Search lists',
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
        suffixIcon: IconButton(
          onPressed: widget.onClose,
          icon: const Icon(Icons.close, color: AppColors.textLight),
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.divider),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

//title row for shopping lists heading, with the search toggle beside it
class _ShoppingListsTitle extends StatelessWidget {
  const _ShoppingListsTitle({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Shopping Lists',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
            fontSize: 34,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 52,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const Spacer(),
        AppIconButton.ghost(
          icon: Icons.search,
          onPressed: onSearchTap,
          customColor: AppColors.textLight,
        ),
      ],
    );
  }
}

//shown when search has no matching lists
class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Text(
        'No shopping lists found.',
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

Future<void> _showCreateListDialog(
  BuildContext context,
  Future<void> Function(String name) onCreateList,
) async {
  final nameController = TextEditingController();

  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.bgLight,
        title: Text(
          'Create Shopping List',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
          ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textLight,
          ),
          decoration: InputDecoration(
            labelText: 'List name',
            labelStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.tertiaryMuted,
            ),
            hintText: 'e.g. Weekend Braai',
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
              Navigator.of(context).pop(nameController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textDark,
            ),
            child: const Text('Create'),
          ),
        ],
      );
    },
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    nameController.dispose();
  });

  final cleanedName = result?.trim() ?? '';
  if (cleanedName.isEmpty) return;

  await onCreateList(cleanedName);

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$cleanedName created.'),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<void> _showListActionsMenu({
  required BuildContext context,
  required ShoppingList list,
  required Future<void> Function(String listId) onDeleteList,
}) async {
  await onDeleteList(list.id);

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${list.title} deleted.'),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<void> _showEditListNameDialog({
  required BuildContext context,
  required ShoppingList list,
  required Future<void> Function({
    required String listId,
    required String name,
  }) onUpdateListName,
}) async {
  final nameController = TextEditingController(text: list.title);

  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.bgLight,
        title: Text(
          'Edit Shopping List',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
          ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textLight,
          ),
          decoration: InputDecoration(
            labelText: 'List name',
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
              Navigator.of(context).pop(nameController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textDark,
            ),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    nameController.dispose();
  });

  final cleanedName = result?.trim() ?? '';
  if (cleanedName.isEmpty || cleanedName == list.title) return;

  await onUpdateListName(
    listId: list.id,
    name: cleanedName,
  );

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$cleanedName saved.'),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}