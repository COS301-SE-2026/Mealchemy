import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_dropdown.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import '../models/meal_plan_entry.dart';
import '../providers/meal_plan_provider.dart';
import 'add_meal_button.dart';
import 'meal_entry_sheet.dart';
import 'meal_plan_day_nav.dart';
import 'meal_plan_entry_card.dart';

class MealPlanSection extends ConsumerStatefulWidget {
  const MealPlanSection({
    super.key,
    required this.vaultId,
    this.canEdit = true,
    this.allowVaultSwitch = false,
  });

  final int vaultId;
  final bool canEdit;
  final bool allowVaultSwitch;

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

  void _openSheet([MealPlanEntry? entry]) {
    showMealEntrySheet(context, vaultId: _vaultId, entry: entry);
  }

  void _openRecipe(MealPlanEntry e) {
    context.push(AppRoutes.recipeDetail.replaceFirst(':id', '${e.recipeId}'));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealPlanProvider(_vaultId));
    final notifier = ref.read(mealPlanProvider(_vaultId).notifier);
    final vaults = ref.watch(vaultsProvider).valueOrNull ?? const <Vault>[];
    final current = vaults.where((v) => v.vaultId == _vaultId).firstOrNull;
    final canSwitch = widget.allowVaultSwitch && vaults.length > 1;

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          current == null ? 'My Plan' : _planName(current),
          style: AppTextStyles.title.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (canSwitch) ...[
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.accent, size: 20),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(title: 'Meal Plan'),
          const SizedBox(height: 8),
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
          const SizedBox(height: 12),
          MealPlanDayNav(
            day: state.selectedDay,
            onPrevious: notifier.previousDay,
            onNext: notifier.nextDay,
            onToday: notifier.goToToday,
          ),
          const SizedBox(height: 16),
          _buildBody(state, notifier),
        ],
      ),
    );
  }

  Widget _buildBody(MealPlanState state, MealPlanNotifier notifier) {
    if (state.isLoading) {
      return const Column(children: [_SkeletonCard(), _SkeletonCard()]);
    }

    if (state.errorMessage != null) {
      return _ErrorState(message: state.errorMessage!, onRetry: notifier.load);
    }

    final entries = state.dayEntries;

    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MealPlanEntryCard(
              entry: e,
              onTap: () => _openRecipe(e),
              onEdit: widget.canEdit ? () => _openSheet(e) : null,
            ),
          ),
        if (entries.isEmpty && !widget.canEdit)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Nothing planned for this day',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          ),
        if (widget.canEdit) AddMealButton(onPressed: () => _openSheet()),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
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