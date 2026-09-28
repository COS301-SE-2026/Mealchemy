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

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

//Pick new list or an existing list, choose all items vs missing only, then send.
Future<void> showAddToSl({
  required BuildContext context,
  required WidgetRef ref,
  required int recipeId,
  required String recipeName,
}) {
  return _open(context, _AddToSl(recipeId: recipeId, recipeName: recipeName));
}

Future<void> showAddPlanToSl({
  required BuildContext context,
  required int planId,
  required DateTime start,
}) {
  return _open(context, _AddToSl(planId: planId, start: start));
}

Future<void> _open(BuildContext context, Widget child) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surfaceWhite,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: child,
    ),
  );
}

class _AddToSl extends ConsumerStatefulWidget {
  const _AddToSl({this.recipeId, this.recipeName, this.planId, this.start});

  final int? recipeId;
  final String? recipeName;
  final int? planId;
  final DateTime? start;

  @override
  ConsumerState<_AddToSl> createState() => _AddToSlState();
}

class _AddToSlState extends ConsumerState<_AddToSl> {
  static const _newListValue = '__new__';

  late DateTime _start = widget.start ?? DateTime.now();
  late DateTime _end = _start.add(const Duration(days: 6));

  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.recipeName ?? _planName());

  String _target = _newListValue;
  bool _missingOnly = true;
  bool _saving = false;

  bool get _isNewList => _target == _newListValue;
  bool get _fromPlan => widget.planId != null;

  String _planName() => 'Meal plan ${_shortDate(_start)} - ${_shortDate(_end)}';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: isStart ? DateTime(now.year - 1) : _start,
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked == null) return;

    //only replace the name if the user hasn't typed their own
    final keepDefault = _nameCtrl.text == _planName();

    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked;
      }
    });

    if (keepDefault) _nameCtrl.text = _planName();
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(shoppingListsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 24),
          if (_fromPlan) ...[
            _label('DATES'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _dateButton(_start, () => _pickDate(isStart: true))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('to', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                ),
                Expanded(child: _dateButton(_end, () => _pickDate(isStart: false))),
              ],
            ),
            const SizedBox(height: 18),
          ],
          _label('DESTINATION'),
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
            _label('LIST NAME'),
            const SizedBox(height: 8),
            AppTextField.standard(
              hint: 'e.g. ${widget.recipeName ?? 'Weekly shop'}',
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

  Widget _label(String text) => Text(text,
      style: AppTextStyles.label.copyWith(color: AppColors.brown, letterSpacing: 1.5));

  Widget _dateButton(DateTime date, VoidCallback onTap) {
    return AppButton.outlined(
      label: _shortDate(date),
      onPressed: onTap,
      isFullWidth: true,
      isRounded: true,
      rightIcon: Icons.calendar_today_outlined,
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
            child: Icon(_fromPlan ? Icons.calendar_month : Icons.add_shopping_cart,
                color: AppColors.textDark, size: 20),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_fromPlan ? 'FROM YOUR MEAL PLAN' : 'SHOPPING LIST',
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
    final source = _fromPlan ? 'these meals' : 'the recipe';
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
                        : 'Adds every ingredient in $source',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                  if (active && _fromPlan && !_isNewList)
                    Text(
                      'Items already on this list are checked too',
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
      String message;

      if (_fromPlan) {
        final skipped = await notifier.addFromMealPlan(
          listId: _isNewList ? null : _target,
          newListName: name,
          planId: widget.planId!,
          startDate: _start,
          endDate: _end,
          compareToPantry: _missingOnly,
        );
        message = skipped == 0
            ? 'Shopping list ready'
            : 'Shopping list ready, $skipped recipes skipped';
      } else if (_isNewList) {
        await notifier.generateFromRecipe(
          recipeId: widget.recipeId!,
          recipeName: name,
          includeMissingOnly: _missingOnly,
        );
        message = 'List created for ${widget.recipeName}';
      } else {
        await notifier.addToExistingList(
          listId: _target,
          recipeId: widget.recipeId!,
          includeMissingOnly: _missingOnly,
        );
        message = 'Added to your list';
      }

      if (mounted) Navigator.pop(context);
      feedback.showShort(
        message,
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