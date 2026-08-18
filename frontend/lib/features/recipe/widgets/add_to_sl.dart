import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/shared_widgets/atoms/app_picker.dart';
import '../../../core/shared_widgets/atoms/app_toast.dart';
import '../../../core/providers/feedback_provider.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../shopping_lists/models/shopping_list.dart';
import '../../shopping_lists/providers/shopping_list_provider.dart';

//Pick new list or an existing list, choose all items vs missing only, then send.
Future<void> showAddToSl({
  required BuildContext context,
  required WidgetRef ref,
  required int recipeId,
  required String recipeName,
}) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surfaceWhite,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: _AddToSl(recipeId: recipeId, recipeName: recipeName),
    ),
  );
}

class _AddToSl extends ConsumerStatefulWidget {
  const _AddToSl({required this.recipeId, required this.recipeName});

  final int recipeId;
  final String recipeName;

  @override
  ConsumerState<_AddToSl> createState() => _AddToSlState();
}

class _AddToSlState extends ConsumerState<_AddToSl> {
  static const _newListValue = '__new__';

  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.recipeName);

  String _target = _newListValue;
  bool _missingOnly = true;
  bool _saving = false;

  bool get _isNewList => _target == _newListValue;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(shoppingListsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 24),
          Text('DESTINATION',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.brown, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          listsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => Text('Could not load your lists.',
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
            data: (state) => _destinationPicker(state.lists),
          ),
          if (_isNewList) ...[
            const SizedBox(height: 18),
            Text('LIST NAME',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.brown, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            AppTextField.standard(
              hint: 'e.g. ${widget.recipeName}',
              controller: _nameCtrl,
              prefixIcon: Icons.edit_outlined,
            ),
          ],
          const SizedBox(height: 22),
          _missingOnlyToggle(),
          const SizedBox(height: 26),
          AppButton.primary(
            label: _isNewList ? 'Create List' : 'Add to List',
            isFullWidth: true,
            isRounded: true,
            isLoading: _saving,
            rightIcon: Icons.arrow_forward,
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.brand,
              borderRadius: BorderRadius.circular(13.5),
            ),
            child: const Icon(Icons.add_shopping_cart,
                color: AppColors.textDark, size: 20),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SHOPPING LIST',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.accentMuted, letterSpacing: 2)),
              const SizedBox(height: 2),
              Text('Create Shopping List',
                  style: AppTextStyles.heading2
                      .copyWith(color: AppColors.primary, fontSize: 22)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _destinationPicker(List<ShoppingList> lists) {
    return AppPicker<String>(
      value: _target,
      iconTone: PickerIconTone.accent,
      options: [
        const AppPickerOption(
          value: _newListValue,
          label: 'New list',
          icon: Icons.add_circle_outline,
        ),
        for (final list in lists)
          AppPickerOption(
            value: list.id,
            label: list.title,
            icon: Icons.list_alt,
          ),
      ],
      onChanged: (v) => setState(() => _target = v),
    );
  }

  Widget _missingOnlyToggle() {
    final active = _missingOnly;
    return GestureDetector(
      onTap: () => setState(() => _missingOnly = !_missingOnly),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(
              active ? Icons.lightbulb : Icons.lightbulb_outline,
              color: active ? AppColors.accent : AppColors.brown,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Smart add',
                      style: AppTextStyles.bodyBold
                          .copyWith(color: AppColors.textLight)),
                  const SizedBox(height: 2),
                  Text(
                    active
                        ? 'Skips items already in your pantry'
                        : 'Adds every ingredient in the recipe',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _gradientSwitch(active),
          ],
        ),
      ),
    );
  }

  Widget _gradientSwitch(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 28,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: active ? AppColors.brand : null,
        color: active ? null : AppColors.inputBorder,
        borderRadius: BorderRadius.circular(14),
        border: active ? Border.all(color: AppColors.accent, width: 1) : null,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final feedback = ref.read(feedbackProvider.notifier);

    if (_isNewList && name.isEmpty) {
      feedback.showShort(
        'Give your list a name.',
        kind: ToastKind.error,
        icon: Icons.error_outline,
      );
      return;
    }

    setState(() => _saving = true);
    final notifier = ref.read(shoppingListsProvider.notifier);

    try {
      if (_isNewList) {
        await notifier.generateFromRecipe(
          recipeId: widget.recipeId,
          recipeName: name,
          includeMissingOnly: _missingOnly,
        );
      } else {
        await notifier.addToExistingList(
          listId: _target,
          recipeId: widget.recipeId,
          includeMissingOnly: _missingOnly,
        );
      }
      if (mounted) Navigator.pop(context);
      feedback.showShort(
        _isNewList
            ? 'List created for ${widget.recipeName}'
            : 'Added to your list',
        kind: ToastKind.success,
        icon: Icons.shopping_cart_checkout,
      );
    } catch (_) {
      setState(() => _saving = false);
      feedback.showShort(
        'Could not update your shopping list. Try again.',
        kind: ToastKind.error,
        icon: Icons.error_outline,
      );
    }
  }
}
