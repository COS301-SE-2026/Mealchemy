import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/providers/feedback_provider.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_confirm_dialog.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_chip.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_picker.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_text_field.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_toast.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_network_image.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import '../models/meal_plan_entry.dart';
import '../models/meal_slot.dart';
import '../providers/meal_plan_provider.dart';
import 'meal_plan_day_nav.dart';
import 'meal_plan_sheet.dart';


const _allFolders = -1;

TimeOfDay _defaultTime(MealSlot slot) {
  switch (slot) {
    case MealSlot.breakfast:
      return const TimeOfDay(hour: 8, minute: 0);
    case MealSlot.lunch:
      return const TimeOfDay(hour: 12, minute: 30);
    case MealSlot.dinner:
      return const TimeOfDay(hour: 18, minute: 30);
    case MealSlot.snack:
      return const TimeOfDay(hour: 15, minute: 0);
  }
}

String _formatCuisine(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
}

Future<void> showMealEntrySheet(
  BuildContext context, {
  required int vaultId,
  MealPlanEntry? entry,
  MealSlot? slot,
}) {
  return showSheet(
    context,
    builder: (_) => _MealEntryForm(vaultId: vaultId, entry: entry, slot: slot),
  );
}

class _MealEntryForm extends ConsumerStatefulWidget {
  const _MealEntryForm({required this.vaultId, this.entry, this.slot});

  final int vaultId;
  final MealPlanEntry? entry;
  final MealSlot? slot;

  @override
  ConsumerState<_MealEntryForm> createState() => _MealEntryFormState();
}

class _MealEntryFormState extends ConsumerState<_MealEntryForm> {
  final _searchCtrl = TextEditingController();
  late final _titleCtrl =
      TextEditingController(text: widget.entry?.title ?? '');
  late final _noteCtrl = TextEditingController(text: widget.entry?.note ?? '');

  late Recipe? _recipe = widget.entry?.recipe;
  late MealSlot _slot =
      widget.entry?.mealSlot ?? widget.slot ?? MealSlot.breakfast;
  late TimeOfDay _time = widget.entry?.mealTime ?? _defaultTime(_slot);
  late bool _searching = widget.entry == null;
  late int _vaultId = widget.vaultId;
  int _folderId = _allFolders;
  bool _suggested = false;
  bool _showValidation = false;

  AppButtonStatus _saveStatus = AppButtonStatus.idle;
  String? _saveError;

  bool get _isEdit => widget.entry != null;
  int? get _recipeId => _recipe?.recipeId ?? widget.entry?.recipeId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _pickRecipe(Recipe recipe, {bool suggested = false}) {
    setState(() {
      _recipe = recipe;
      _suggested = suggested;
      _searching = false;
      _searchCtrl.clear();
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_recipeId == null || !_slot.allows(_time)) {
      setState(() {
        _showValidation = true;
        _saveStatus = AppButtonStatus.error;
        _saveError = null;
      });
      return;
    }

    setState(() {
      _saveStatus = AppButtonStatus.loading;
      _saveError = null;
    });

    final notifier = ref.read(mealPlanProvider(widget.vaultId).notifier);
    final title = _titleCtrl.text.trim();
    final note = _noteCtrl.text.trim();

    final entry = MealPlanEntry(
      entryId: widget.entry?.entryId,
      planId: widget.entry?.planId,
      recipeId: _recipeId!,
      entryDate: widget.entry?.entryDate ??
          ref.read(mealPlanProvider(widget.vaultId)).selectedDay,
      mealSlot: _slot,
      mealTime: _time,
      title: title.isEmpty ? null : title,
      note: note.isEmpty ? null : note,
      source: widget.entry?.source ?? MealEntrySource.manual,
      addedBy: widget.entry?.addedBy,
      recipe: _recipe,
    );

    String? error;
    if (_isEdit) {
      error = await notifier.updateEntry(entry);
    } else if (_suggested) {
      error = await notifier.acceptRecommendation(entry);
    } else {
      error = await notifier.addEntry(entry);
    }

    if (!mounted) return;
    setState(() {
      _saveStatus =
          error == null ? AppButtonStatus.success : AppButtonStatus.error;
      _saveError = error;
    });
  }

  Future<void> _delete() async {
    final ok = await showAppConfirmDialog(
      context: context,
      title: 'Remove meal',
      message: 'Take this meal off your plan?',
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (ok != true || !mounted) return;
    final feedback = ref.read(feedbackProvider.notifier);
    final error = await ref
        .read(mealPlanProvider(widget.vaultId).notifier)
        .deleteEntry(widget.entry!.entryId!);
    if (!mounted) return;

    if (error != null) {
      feedback.showShort(error,
          kind: ToastKind.error, icon: Icons.error_outline);
      return;
    }
    Navigator.of(context).pop();
    feedback.showShort('Meal removed',
        kind: ToastKind.success, icon: Icons.check_circle_outline);
  }

  @override
  Widget build(BuildContext context) {
    final vaults = ref.watch(vaultsProvider).valueOrNull ?? const <Vault>[];
    final planVault =
        vaults.where((v) => v.vaultId == widget.vaultId).firstOrNull;
    final isPrivate = planVault?.vaultType == VaultTypes.private;
    final DateTime day = widget.entry?.entryDate ??
        ref.watch(mealPlanProvider(widget.vaultId)).selectedDay;

    return MealPlanSheet(
      title: _isEdit ? 'Edit Meal' : 'Add Meal',
      subtitle: MealPlanDayNav.formatDay(day),
      readOnlyWhenOffline: true,
      footer: Column(
        children: [
          AppButton.primary(
            label: _isEdit ? 'Save Changes' : 'Add to Plan',
            onPressed: _save,
            isFullWidth: true,
            isRounded: true,
            status: _saveStatus,
            errorMessage: _saveError,
            onSuccessComplete: () => Navigator.of(context).pop(),
          ),
          if (_isEdit)
            AppButton.text(
              label: 'Remove from plan',
              onPressed: _delete,
              customColor: AppColors.error,
            ),
        ],
      ),
      children: [
        //recipe
        const AppSectionHeader(title: 'Recipe'),
        const SizedBox(height: 14),
        if (!_searching)
          _selectedRecipe()
        else ...[
          //engine suggestions only work for your private plan

          if (!_isEdit && isPrivate)
            _Suggestions(
              vaultId: widget.vaultId,
              date: day,
              slot: _slot,
              onPick: (r) => _pickRecipe(r, suggested: true),
            ),
          _search(vaults, planVault, isPrivate),
        ],
        if (_showValidation && _recipeId == null)
          const _ValidationText('Pick a recipe for this meal.'),
        const SizedBox(height: 28),

        //when
        const AppSectionHeader(title: 'When'),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MealSlot.values
              .map((s) => AppChip(
                    label: s.label,
                    selected: s == _slot,
                    onTap: () => setState(() {
                      _slot = s;
                      _time = _defaultTime(s);
                    }),
                  ))
              .toList(),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton.outlined(
            label: MealPlanEntry.formatTime(_time),
            onPressed: _pickTime,
            isRounded: true,
            rightIcon: Icons.schedule,
          ),
        ),
        if (_showValidation && !_slot.allows(_time))
          _ValidationText(
              'That time does not fit ${_slot.label.toLowerCase()}.'),
        const SizedBox(height: 28),

        //details
        const AppSectionHeader(title: 'Details'),
        const SizedBox(height: 14),
        AppTextField.standard(
          label: 'Display name (optional)',
          hint: _recipe?.title ??
              widget.entry?.displayTitle ??
              'Uses the recipe name',
          controller: _titleCtrl,
        ),
        const SizedBox(height: 14),
        AppTextField.standard(
          label: 'Note (optional)',
          hint: 'e.g. Meal prepped',
          controller: _noteCtrl,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _selectedRecipe() {
    final title = _recipe?.title ?? widget.entry?.displayTitle ?? '';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _Thumb(photoUrl: _recipe?.photoUrl, size: 48),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.cardTitle.copyWith(color: AppColors.textLight),
      ),
      subtitle: Text(
        _suggested ? 'Suggested' : _formatCuisine(_recipe?.cuisineType),
        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
      ),
      trailing: GestureDetector(
        onTap: () => setState(() => _searching = true),
        child: Text(
          'Change',
          style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _search(List<Vault> vaults, Vault? planVault, bool isPrivate) {
    final folders =
        ref.watch(vaultFoldersProvider(_vaultId)).valueOrNull ?? const [];
    final folderIds = _folderId == _allFolders
        ? folders.map((f) => f.folderId).toList()
        : [_folderId];
    final lists = folderIds
        .map((id) => ref.watch(folderRecipeDisplayProvider(id)))
        .toList();
    final loading = lists.any((l) => l.isLoading);

    //same recipe can sit in more than one folder
    final seen = <int>{};
    final recipes = <Recipe>[];
    for (final l in lists) {
      for (final r in l.valueOrNull ?? const <Recipe>[]) {
        if (seen.add(r.recipeId)) recipes.add(r);
      }
    }

    final query = _searchCtrl.text.trim().toLowerCase();
    final matches = recipes.where((r) => r.title.toLowerCase().contains(query));
    final results = query.isEmpty ? matches.take(5).toList() : matches.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              //shared plans can only use recipes from that vault
              child: isPrivate
                  ? AppPicker<int>(
                      value: _vaultId,
                      options: vaults
                          .map((v) =>
                              AppPickerOption(value: v.vaultId, label: v.name))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _vaultId = v;
                        _folderId = _allFolders;
                      }),
                    )
                  : AppPicker<int>(
                      value: widget.vaultId,
                      enabled: false,
                      options: [
                        AppPickerOption(
                          value: widget.vaultId,
                          label: planVault?.name ?? 'This vault',
                        ),
                      ],
                      onChanged: (_) {},
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppPicker<int>(
                value: _folderId,
                options: [
                  const AppPickerOption(
                      value: _allFolders, label: 'All folders'),
                  ...folders.map((f) =>
                      AppPickerOption(value: f.folderId, label: f.folderName)),
                ],
                onChanged: (v) => setState(() => _folderId = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField.standard(
          hint: 'Search your recipes',
          controller: _searchCtrl,
          prefixIcon: Icons.search,
          onChanged: (_) => setState(() {}),
        ),
        if (loading)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: LinearProgressIndicator(),
          )
        else if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'No recipes found',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          )
        else
          ...results.map((r) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: _Thumb(photoUrl: r.photoUrl, size: 40),
                title: Text(
                  r.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _formatCuisine(r.cuisineType),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
                trailing: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primaryLight,
                  size: 22,
                ),
                onTap: () => _pickRecipe(r),
              )),
        if (_isEdit)
          AppButton.text(
            label: 'Keep current recipe',
            onPressed: () => setState(() => _searching = false),
            customColor: AppColors.primary,
          ),
      ],
    );
  }
}

class _Suggestions extends ConsumerWidget {
  const _Suggestions({
    required this.vaultId,
    required this.date,
    required this.slot,
    required this.onPick,
  });

  final int vaultId;
  final DateTime date;
  final MealSlot slot;
  final ValueChanged<Recipe> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref
            .watch(mealSuggestionsProvider(
                (vaultId: vaultId, date: date, slot: slot)))
            .valueOrNull ??
        const <Recipe>[];

    if (recipes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUGGESTED FOR ${slot.label.toUpperCase()}',
          style: AppTextStyles.label
              .copyWith(color: AppColors.accentMuted, letterSpacing: 1),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final r = recipes[i];
              return GestureDetector(
                onTap: () => onPick(r),
                child: SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          _Thumb(photoUrl: r.photoUrl, size: 120, height: 90),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceWhite,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add,
                                  size: 18, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.photoUrl, required this.size, this.height});

  final String? photoUrl;
  final double size;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: height ?? size,
        child: RecipeNetworkImage(
          photoUrl: photoUrl,
          placeholder: Container(
            decoration: const BoxDecoration(gradient: AppColors.brand),
          ),
        ),
      ),
    );
  }
}

class _ValidationText extends StatelessWidget {
  const _ValidationText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
    );
  }
}
