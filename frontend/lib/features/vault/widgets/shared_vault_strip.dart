import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_input_dialog.dart';
import '../providers/vault_repository_provider.dart';
import '../providers/vault_provider.dart';

// Horizontal strip of shared vault avatars with a trailing add circle,
// shown only in shared mode.
class SharedVaultStrip extends ConsumerWidget {
  const SharedVaultStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isSharedModeProvider)) return const SizedBox.shrink();

    final shared = ref.watch(sharedVaultsProvider);
    final selected = ref.watch(selectedVaultProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: SizedBox(
        height: 96,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // trailing add circle, always last
            _StripItem(
              label: 'Add Vault',
              selected: false,
              //Implement the onTap to navigate to the add vault screen(doing this later)
              onTap: () => _createVault(context, ref),
              child: const Icon(
                Icons.add,
                color: AppColors.accentMuted,
                size: 26,
              ),
            ),
            for (final vault in shared)
              _StripItem(
                label: vault.name,
                selected: vault.vaultId == selected?.vaultId,
                onTap: () => ref.read(selectedVaultIdProvider.notifier).state =
                    vault.vaultId,
                child: Text(
                  vault.name.isEmpty ? '?' : vault.name[0].toUpperCase(),
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StripItem extends StatelessWidget {
  const _StripItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: AppColors.accent, width: 2.5)
                    : Border.all(color: AppColors.divider, width: 1),
              ),
              child: child,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 68,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _createVault(BuildContext context, WidgetRef ref) async {
    final name = await showAppInputDialog(
      context: context,
      title: 'New Shared Vault',
      label: 'Vault Name',
      hint: 'e.g. Family Recipes',
      confirmLabel: 'Create',
      prefixIcon: Icons.group_outlined,
    );
    if (name == null) return;

    final vault = await ref.read(vaultRepositoryProvider).createVault(name);
    ref.invalidate(vaultsProvider);
    ref.read(selectedVaultIdProvider.notifier).state = vault.vaultId;
  }