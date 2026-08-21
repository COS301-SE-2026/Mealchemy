import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/shared_widgets/atoms/app_multi_select.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';

class InformationSection extends ConsumerWidget {
  const InformationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader.icon(
          subtitle: 'About you',
          title: 'Your Account',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        profileAsync.when(
          loading: () => const _MetadataSkeleton(),
          error: (_, __) => _ErrorLine(
            message: 'Could not load your account.',
            onRetry: () => ref.read(profileProvider.notifier).reload(),
          ),
          data: (edit) => _InformationBody(profile: edit.draft),
        ),
      ],
    );
  }
}

class _InformationBody extends ConsumerWidget {
  const _InformationBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(profileProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IdentityCard(profile: profile),
        const SizedBox(height: 26),
        const AppSectionHeader(
          title: 'Preferred Units',
          leadingIcon: Icons.straighten,
        ),
        const SizedBox(height: 14),
        _UnitToggle(
          value: profile.preferredUnit,
          onChanged: notifier.setPreferredUnit,
        ),
        const SizedBox(height: 26),
        const AppSectionHeader(
          title: 'Your Kitchen',
          leadingIcon: Icons.kitchen_outlined,
        ),
        const SizedBox(height: 12),
        Text(
          'What you cook with, for better recipe matches.',
          style: AppTextStyles.bodyBold.copyWith(color: AppColors.textLight),
        ),
        const SizedBox(height: 14),
        _EquipmentPicker(selected: profile.equipment),
      ],
    );
  }
}

class _EquipmentPicker extends ConsumerWidget {
  const _EquipmentPicker({required this.selected});

  final List<String> selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(equipmentOptionsProvider);
    final notifier = ref.read(profileProvider.notifier);

    return optionsAsync.when(
      loading: () => const _ChipRowSkeleton(),
      error: (_, __) => Text(
        'Could not load equipment options.',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
      data: (options) => AppMultiSelect(
        addLabel: 'Add equipment',
        surface: MultiSelectSurface.white,
        options: [
          for (final o in options)
            MultiSelectOption(value: o.value, label: o.label),
        ],
        selectedValues: selected,
        onToggle: notifier.toggleEquipment,
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          _Avatar(profile: profile),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textLight,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.mail_outline,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        profile.email,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final url = profile.avatarUrl;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: url == null ? AppColors.brand : null,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null
          ? Image.network(url,
              fit: BoxFit.cover, errorBuilder: (_, __, ___) => _initials())
          : _initials(),
    );
  }

  Widget _initials() {
    return Center(
      child: Text(
        profile.initials,
        style: AppTextStyles.title.copyWith(
          color: AppColors.textDark,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.value, required this.onChanged});

  final PreferredUnit value;
  final ValueChanged<PreferredUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          for (final unit in PreferredUnit.values)
            Expanded(child: _segment(unit, unit == value)),
        ],
      ),
    );
  }

  Widget _segment(PreferredUnit unit, bool selected) {
    return GestureDetector(
      onTap: () => onChanged(unit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.brand : null,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(
          unit.label,
          style: AppTextStyles.bodyBold.copyWith(
            color: selected ? AppColors.textDark : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _MetadataSkeleton extends StatelessWidget {
  const _MetadataSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
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
        for (var i = 0; i < 4; i++)
          Container(
            width: 84,
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