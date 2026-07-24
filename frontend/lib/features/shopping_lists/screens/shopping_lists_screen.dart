import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/Organisms/app_navbar.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/shopping_list.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/shopping_list_row.dart';
import '../widgets/shopping_section_header.dart';

//main overview screen
class ShoppingListsScreen extends ConsumerWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists = ref.watch(shoppingListsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: shoppingLists.when(
        data: (state) => _ShoppingListsContent(
          state: state,
          onSearchChanged: (query) {
            ref.read(shoppingListsProvider.notifier).updateSearchQuery(query);
          },
          onCreateList: (name) async {
            await ref.read(shoppingListsProvider.notifier).createShoppingList(
                  name: name,
                );
          },
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (_, __) => Center(
          child: Text(
            'Unable to load shopping lists.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(
          context,
          (name) async {
            await ref.read(shoppingListsProvider.notifier).createShoppingList(
                  name: name,
                );
          },
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
        elevation: 8,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: AppNavbar(
        currentRoute: AppRoutes.shoppingLists,
        onRouteSelected: (route) => context.go(route),
      ),
    );
  }
}

//loaded content for shopping lists overview screen
class _ShoppingListsContent extends StatelessWidget {
  const _ShoppingListsContent({
    required this.state,
    required this.onSearchChanged,
    required this.onCreateList,
  });

  final ShoppingListsState state;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function(String name) onCreateList;

  @override
  Widget build(BuildContext context) {
    final groupedLists = state.groupedFilteredLists;
    final listWidgets = state.filteredLists.isEmpty
        ? <Widget>[const _EmptySearchState()]
        : _buildSections(
            context: context,
            groupedLists: groupedLists,
          );

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 96),
        children: [
          _ShoppingListsTopBar(
            searchQuery: state.searchQuery,
            onSearchChanged: onSearchChanged,
            onCreateList: onCreateList,
          ),
          const SizedBox(height: 26),
          const _ShoppingListsTitle(),
          const SizedBox(height: 30),
          ShoppingSectionHeader(
            title: 'Lists',
            trailing: '${state.filteredLists.length} lists',
          ),
          const SizedBox(height: 34),
          ...listWidgets,
        ],
      ),
    );
  }

  //builds each grouped shopping list section
  List<Widget> _buildSections({
    required BuildContext context,
    required Map<String, List<ShoppingList>> groupedLists,
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
            onTap: () {
              if (list.id == 'general-list') {
                context.go('/shopping-lists/${list.id}');
              }
            },
          ),
        );
      }

      widgets.add(const SizedBox(height: 18));
    }

    return widgets;
  }
}

//top icon row for search/add/camera actions
class _ShoppingListsTopBar extends StatefulWidget {
  const _ShoppingListsTopBar({
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onCreateList,
  });

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function(String name) onCreateList;

  @override
  State<_ShoppingListsTopBar> createState() => _ShoppingListsTopBarState();
}

class _ShoppingListsTopBarState extends State<_ShoppingListsTopBar> {
  late final TextEditingController _searchController;
  var _searchOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant _ShoppingListsTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //clears search, closes search field
  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');

    setState(() {
      _searchOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_searchOpen) {
      return TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: widget.onSearchChanged,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textLight,
        ),
        decoration: InputDecoration(
          hintText: 'Search lists',
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textMuted,
          ),
          suffixIcon: IconButton(
            onPressed: _clearSearch,
            icon: const Icon(
              Icons.close,
              color: AppColors.textLight,
            ),
          ),
          filled: true,
          fillColor: AppColors.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColors.divider,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColors.primary,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _searchOpen = true;
            });
          },
          icon: const Icon(
            Icons.search,
            color: AppColors.textLight,
            size: 28,
          ),
        ),
        const Spacer(),
        Column(
          children: [
            IconButton(
              onPressed: () =>
                  _showCreateListDialog(context, widget.onCreateList),
              icon: const Icon(
                Icons.add,
                color: AppColors.textLight,
                size: 32,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.textLight,
                size: 26,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//title row for shopping lists heading
class _ShoppingListsTitle extends StatelessWidget {
  const _ShoppingListsTitle();

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
