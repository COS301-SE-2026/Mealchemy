import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/providers/feedback_provider.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_confirm_dialog.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_dropdown.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_toast.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/recipe/widgets/add_to_sl.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_folder_management_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import '../models/meal_plan_entry.dart';
import '../models/meal_slot.dart';
import '../providers/meal_plan_provider.dart';
import 'meal_entry_sheet.dart';
import 'meal_plan_day_nav.dart';
import 'meal_plan_entry_card.dart';

class MealPlanSection extends ConsumerStatefulWidget {
  const MealPlanSection({
    super.key,
    required this.vaultId,
    this.canEdit = true,
    this.allowVaultSwitch = false,
    this.showPlanName = true,
  });

  final int vaultId;
  final bool canEdit;
  final bool allowVaultSwitch;
  final bool showPlanName;

  @override
  ConsumerState<MealPlanSection> createState() => _MealPlanSectionState();
}

class _MealPlanSectionState extends ConsumerState<MealPlanSection> {
  late int _vaultId = widget.vaultId;

  @override
  void didUpdateWidget(covariant MealPlanSection old) {
    super.didUpdateWidget(old);
    if (old.vaultId != widget.vaultId) _vaultId = widget.vaultId;
  }

  String _planName(Vault v) =>
      v.vaultType == VaultTypes.private ? 'My Plan' : v.name;

  void _openSheet({MealPlanEntry? entry, MealSlot? slot}) {
    final defaultSlot = ref.read(mealPlanProvider(_vaultId)).firstFreeSlot;
    showMealEntrySheet(
      context,
      vaultId: _vaultId,
      entry: entry,
      slot: slot ?? defaultSlot,
    );
  }

  void _openRecipe(MealPlanEntry e) {
    context.push(AppRoutes.recipeDetail.replaceFirst(':id', '${e.recipeId}'));
  }

  void _openShoppingList(MealPlanState state) {
    final plan = state.plan;
    if (plan == null) return;
    showAddPlanToSl(context: context, planId: plan.planId, start: state.selectedDay);
  }

  Future<void> _clearDay() async {
    final ok = await showAppConfirmDialog(
      context: context,
      title: 'Clear day',
      message: 'Remove every meal planned for this day?',
      confirmLabel: 'Clear',
      isDestructive: true,
    );
    if (ok != true) return;

    final error = await ref.read(mealPlanProvider(_vaultId).notifier).clearDay();
    final feedback = ref.read(feedbackProvider.notifier);
    if (error != null) {
      feedback.showShort(error, kind: ToastKind.error, icon: Icons.error_outline);
    } else {
      feedback.showShort('Day cleared', kind: ToastKind.success, icon: Icons.check_circle_outline);
    }
  }

  List<AppDropdownItem> _menuItems(MealPlanState state, bool canEdit) {
    return [
      if (canEdit)
        AppDropdownItem(label: 'Add meal', icon: Icons.add, onTap: () => _openSheet()),
      AppDropdownItem(
        label: 'Generate shopping list',
        icon: Icons.shopping_cart_outlined,
        onTap: () => _openShoppingList(state),
      ),
      if (canEdit && state.dayEntries.isNotEmpty)
        AppDropdownItem(
          label: 'Clear day',
          icon: Icons.delete_outline,
          destructive: true,
          onTap: _clearDay,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealPlanProvider(_vaultId));
    final notifier = ref.read(mealPlanProvider(_vaultId).notifier);
    final vaults = ref.watch(vaultsProvider).valueOrNull ?? const <Vault>[];
    final current = vaults.where((v) => v.vaultId == _vaultId).firstOrNull;
    final canSwitch = widget.allowVaultSwitch && vaults.length > 1;

    final canManage =
        current != null && ref.watch(canManageVaultFoldersProvider(current));
    final checkingAccess = current == null ||
        (current.vaultType == VaultTypes.shared &&
            ref.watch(sharedVaultAccessProvider(current.vaultId)).isLoading);
    final canEdit = widget.canEdit && canManage;
    final viewOnly = !canEdit && !checkingAccess;

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          current == null ? 'My Plan' : _planName(current),
          style: AppTextStyles.heading2.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (canSwitch) ...[
          const SizedBox(width: 2),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.accent, size: 18),
        ],
      ],
    );

    final menu = AppDropdown(
      trigger: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
      ),
      items: _menuItems(state, canEdit),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showPlanName) ...[
            const AppSectionHeader(title: 'Meal Plan'),
            const SizedBox(height: 6),
            Row(
              children: [
                canSwitch
                    ? AppDropdown(
                        trigger: label,
                        items: vaults
                            .map((v) => AppDropdownItem(
                                  label: _planName(v),
                                  icon: v.vaultType == VaultTypes.private
                                      ? Icons.person_outline
                                      : Icons.group_outlined,
                                  onTap: () => setState(() => _vaultId = v.vaultId),
                                ))
                            .toList(),
                      )
                    : label,
                const Spacer(),
                if (viewOnly) ...[
                  const _ViewOnlyTag(),
                  const SizedBox(width: 4),
                ],
                menu,
              ],
            ),
          ] else
            Row(
              children: [
                const Expanded(child: AppSectionHeader(title: 'Meal Plan')),
                if (viewOnly) ...[
                  const _ViewOnlyTag(),
                  const SizedBox(width: 4),
                ],
                menu,
              ],
            ),
          const SizedBox(height: 8),
          MealPlanDayNav(
            day: state.selectedDay,
            onPrevious: notifier.previousDay,
            onNext: notifier.nextDay,
            onToday: notifier.goToToday,
            onDateSelected: notifier.selectDay,
          ),
          const SizedBox(height: 16),
          _buildBody(state, notifier, canEdit),
        ],
      ),
    );
  }

  Widget _buildBody(MealPlanState state, MealPlanNotifier notifier, bool canEdit) {
    if (state.isLoading) {
      return const Column(children: [_SkeletonCard(), _SkeletonCard()]);
    }

    if (state.errorMessage != null) {
      return _ErrorState(message: state.errorMessage!, onRetry: notifier.load);
    }

    final entries = state.dayEntries;

    if (entries.isEmpty && !canEdit) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.event_note_outlined, size: 28, color: AppColors.textMuted),
              const SizedBox(height: 8),
              Text(
                'Nothing planned yet',
                style: AppTextStyles.bodyBold.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 2),
              Text(
                "The vault owner hasn't added meals for this day.",
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    int minutes(TimeOfDay t) => t.hour * 60 + t.minute;

    final rows = <({int at, Widget child})>[
      for (final e in entries)
        (
          at: minutes(e.mealTime),
          child: MealPlanEntryCard(
            entry: e,
            onTap: () => _openRecipe(e),
            onEdit: canEdit ? () => _openSheet(entry: e) : null,
          ),
        ),
      if (canEdit)
        for (final slot in [MealSlot.breakfast, MealSlot.lunch, MealSlot.dinner])
          if (!entries.any((e) => e.mealSlot == slot))
            (
              at: minutes(slot.earliest!),
              child: _AddSlotRow(slot: slot, onTap: () => _openSheet(slot: slot)),
            ),
    ]..sort((a, b) => a.at.compareTo(b.at));

    return Column(
      children: [
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: r.child,
          ),
        if (canEdit && entries.any((e) => e.mealSlot != MealSlot.snack))
          _AddSlotRow(onTap: () => _openSheet()),
      ],
    );
  }
}

class _ViewOnlyTag extends StatelessWidget {
  const _ViewOnlyTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.visibility_outlined, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            'VIEW ONLY',
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _AddSlotRow extends StatelessWidget {
  const _AddSlotRow({this.slot, required this.onTap});

  final MealSlot? slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Icon(slot?.icon ?? Icons.restaurant_outlined, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text(
              slot?.label.toUpperCase() ?? 'ANOTHER MEAL',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            const Icon(Icons.add, size: 18, color: AppColors.primaryLight),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: AppTextStyles.bodyBold.copyWith(color: AppColors.primaryLight),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          AppButton.text(
            label: 'Try again',
            onPressed: onRetry,
            customColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}