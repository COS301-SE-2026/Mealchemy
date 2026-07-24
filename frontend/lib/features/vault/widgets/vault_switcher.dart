import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

import '../providers/vault_provider.dart';

class VaultSwitcher extends ConsumerWidget {
  const VaultSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaults = ref.watch(vaultsProvider).valueOrNull;
    final isShared = ref.watch(isSharedModeProvider);
    if (vaults == null) return const SizedBox.shrink();

    return PopupMenuButton<bool>(
      // value is the target mode: false = private, true = shared
      onSelected: (toShared) {
        ref.read(isSharedModeProvider.notifier).state = toShared;
        ref.read(selectedVaultIdProvider.notifier).state = null;
      },
      color: AppColors.bgLight,
      elevation: 4,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        _modeItem(
          value: false,
          icon: Icons.lock,
          label: 'Private Vault',
          checked: !isShared,
        ),
        _modeItem(
          value: true,
          icon: Icons.group_outlined,
          label: 'Shared Vaults',
          checked: isShared,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isShared ? Icons.group_outlined : Icons.lock,
              size: 20,
              color: AppColors.accent,
            ),
            const SizedBox(width: 8),
            Text(
              isShared ? 'Shared Vaults' : 'Private Vault',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<bool> _modeItem({
    required bool value,
    required IconData icon,
    required String label,
    required bool checked,
  }) {
    return PopupMenuItem<bool>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.title.copyWith(color: AppColors.textLight),
          ),
          const Spacer(),
          if (checked)
            const Icon(Icons.check, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}