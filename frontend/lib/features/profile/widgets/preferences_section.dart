import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/shared_widgets/atoms/app_multi_select.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/preference_option.dart';
import '../models/user_preferences.dart';
import '../providers/profile_provider.dart';
import 'aversions_section.dart';

class PreferencesSection extends ConsumerWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(preferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader.icon(
          subtitle: 'Your taste',
          title: 'Preferences',
          icon: Icons.tune,
        ),
        const SizedBox(height: 22),
        prefsAsync.when(
          loading: () => const _SectionSkeleton(),
          error: (_, __) => _ErrorLine(
            message: 'Could not load your preferences.',
            onRetry: () => ref.read(preferencesProvider.notifier).reload(),
          ),
          data: (edit) => _PreferencesBody(prefs: edit.draft),
        ),
      ],
    );
  }
}

class _PreferencesBody extends ConsumerWidget {
  const _PreferencesBody({required this.prefs});

  final UserPreferences prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(preferencesProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Dietary Directives',
          leadingIcon: Icons.restaurant_menu,
        ),
        const SizedBox(height: 12),
        _CatalogMultiSelect(
          optionsProvider: dietaryOptionsProvider,
          selected: prefs.dietaryRestrictions,
          onToggle: notifier.toggleDietary,
          addLabel: 'Add restriction',
          description: 'Rules we\'ll always cook around.',
        ),
        const SizedBox(height: 28),

        const AppSectionHeader(
          title: 'Critical Allergies',
          leadingIcon: Icons.warning_amber_rounded,
        ),
        const SizedBox(height: 12),
        _CatalogMultiSelect(
          optionsProvider: allergyOptionsProvider,
          selected: prefs.allergies,
          onToggle: notifier.toggleAllergy,
          addLabel: 'Add allergy',
          description: 'Ingredients we\'ll always keep out.',
        ),
        const SizedBox(height: 28),

        const AppSectionHeader(
          title: 'Aversions',
          leadingIcon: Icons.thumb_down_alt_outlined,
        ),
        const SizedBox(height: 12),
        Text(
          'Things you\'d rather not see in recommendations.',
          style: AppTextStyles.bodyBold.copyWith(color: AppColors.textLight),
        ),
        const SizedBox(height: 14),
        AversionsSection(disliked: prefs.dislikedIngredients),
        const SizedBox(height: 28),

        const AppSectionHeader(
          title: 'Flavour Profiles',
          leadingIcon: Icons.local_dining,
        ),
        const SizedBox(height: 12),
        _CatalogMultiSelect(
          optionsProvider: flavourOptionsProvider,
          selected: prefs.flavourProfile,
          onToggle: notifier.toggleFlavour,
          addLabel: 'Add cuisine',
          description: 'Cuisines you lean towards.',
        ),
        const SizedBox(height: 28),

        const AppSectionHeader(
          title: 'Nutritional Goals',
          leadingIcon: Icons.monitor_heart_outlined,
        ),
        const SizedBox(height: 12),
        _CatalogMultiSelect(
          optionsProvider: goalOptionsProvider,
          selected: prefs.nutritionalGoals,
          onToggle: notifier.toggleGoal,
          addLabel: 'Add goal',
          description: 'What we\'ll steer your meals towards.',
        ),
      ],
    );
  }
}

class _CatalogMultiSelect extends ConsumerWidget {
  const _CatalogMultiSelect({
    required this.optionsProvider,
    required this.selected,
    required this.onToggle,
    required this.addLabel,
    required this.description,
  });

  final ProviderListenable<AsyncValue<List<PreferenceOption>>> optionsProvider;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final String addLabel;
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(optionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: AppTextStyles.bodyBold.copyWith(color: AppColors.textLight),
        ),
        const SizedBox(height: 14),
        optionsAsync.when(
          loading: () => const _ChipRowSkeleton(),
          error: (_, __) => Text(
            'Could not load options.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
          data: (options) => AppMultiSelect(
            addLabel: addLabel,
            surface: MultiSelectSurface.white,
            options: [
              for (final o in options)
                MultiSelectOption(value: o.value, label: o.label),
            ],
            selectedValues: selected,
            onToggle: onToggle,
          ),
        ),
      ],
    );
  }
}

class _ChipRowSkeleton extends StatelessWidget {
  const _ChipRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 90,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      ],
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
      ],
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}