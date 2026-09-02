import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_card.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_input_dialog.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/dashboard/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';

class SmartSuggestionCard extends ConsumerWidget {
  const SmartSuggestionCard({super.key});

  Future<void> _createList(BuildContext context, WidgetRef ref) async {
    final name = await showAppInputDialog(
      context: context,
      title: 'New shopping list',
      label: 'List name',
      hint: 'Weekend Cooking',
      confirmLabel: 'Create',
      prefixIcon: Icons.shopping_cart_outlined,
    );

    if (name == null) return;

    await ref.read(shoppingListsProvider.notifier).createShoppingList(
          name: name,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newestList = ref.watch(newListProvider);

    return AppCard.gradient(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Gold eyebrow label
          Text(
            'SMART SUGGESTION',
            style: AppTextStyles.label.copyWith(
              color: AppColors.accent,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          if (newestList == null)
            _EmptyPrompt(onTap: () => _createList(context, ref))
          else
            Text(
              _messageFor(newestList),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textDark,
              ),
            ),
          const SizedBox(height: 16),

          //Small icon to hint at action
          Icon(
            Icons.lightbulb_outline,
            color: AppColors.accent,
            size: 20,
          ),
        ],
      ),
    );
  }
}

String _messageFor(ShoppingList list) {
  if (list.itemCount == 0) {
    return '${list.title} is empty. Add items to get started.';
  }

  final noun = list.itemCount == 1 ? 'item' : 'items';
  return "You've got ${list.itemCount} $noun to buy on ${list.title}.";
}

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No shopping lists yet.',
          style: AppTextStyles.body.copyWith(color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Create your first list',
            style: AppTextStyles.bodyBold.copyWith(
              color: AppColors.accent,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}