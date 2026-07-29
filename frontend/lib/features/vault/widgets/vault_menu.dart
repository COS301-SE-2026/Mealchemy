import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_confirm_dialog.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_input_dialog.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import '../providers/vault_repository_provider.dart';
import '../models/vault.dart';
import '../providers/vault_provider.dart';

enum _VaultAction { createFolder, addMember, deleteVault, leaveVault }

class VaultMenuButton extends ConsumerWidget {
  const VaultMenuButton({super.key, required this.vault});

  final Vault vault;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authProvider).userId;
    final isOwner = vault.ownerId == currentUserId;

    return PopupMenuButton<_VaultAction>(
      icon: const Icon(Icons.more_vert, color: AppColors.primary),
      color: AppColors.bgLight,
      elevation: 4,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (action) => _handle(context, ref, action),
      itemBuilder: (context) {
        if (!isOwner) {
          return [
            PopupMenuItem<_VaultAction>(
              value: _VaultAction.leaveVault,
              child: _row(Icons.logout, 'Leave vault (coming soon)'),
            ),
          ];
        }
        final isShared = vault.vaultType == VaultTypes.shared;
        return [
          PopupMenuItem<_VaultAction>(
            value: _VaultAction.createFolder,
            child: _row(Icons.create_new_folder_outlined, 'Create folder'),
          ),
          if (isShared) ...[
            PopupMenuItem<_VaultAction>(
              value: _VaultAction.addMember,
              child: _row(Icons.person_add_alt, 'Add member'),
            ),
            PopupMenuItem<_VaultAction>(
              value: _VaultAction.deleteVault,
              child: _row(Icons.delete_forever_outlined, 'Delete vault',
                  destructive: true),
            ),
          ],
        ];
      },
    );
  }

  Widget _row(IconData icon, String label, {bool destructive = false}) {
    final color = destructive ? AppColors.error : AppColors.textLight;
    return Row(
      children: [
        Icon(icon,
            size: 20, color: destructive ? AppColors.error : AppColors.accent),
        const SizedBox(width: 10),
        Flexible(
            child:
                Text(label, style: AppTextStyles.title.copyWith(color: color))),
      ],
    );
  }

  Future<void> _handle(
      BuildContext context, WidgetRef ref, _VaultAction action) async {
    switch (action) {
      case _VaultAction.addMember:
        final email = await showAppInputDialog(
          context: context,
          title: 'Add Member',
          label: 'Email',
          hint: 'chef@mealchemy.com',
          confirmLabel: 'Add',
          prefixIcon: Icons.email_outlined,
        );
        if (email == null) return;
        if (!context.mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        try {
          await ref
              .read(vaultRepositoryProvider)
              .addMember(vault.vaultId, email);
          ref.invalidate(vaultMembersProvider(vault.vaultId));
          messenger.showSnackBar(
            SnackBar(content: Text('$email added to the vault')),
          );
        } catch (e) {
          final message = e is DioException && e.response?.data is Map
              ? (e.response?.data as Map)['message'] as String? ??
                  'Could not add member.'
              : 'Could not add member.';
          messenger.showSnackBar(SnackBar(content: Text(message)));
        }

      case _VaultAction.deleteVault:
        final ok = await showAppConfirmDialog(
          context: context,
          title: 'Delete Vault',
          message:
              'Delete "${vault.name}" for everyone? All its folders and recipes will be removed. This cannot be undone.',
          confirmLabel: 'Delete',
          isDestructive: true,
        );
        if (ok != true) return;
        await ref.read(vaultRepositoryProvider).deleteVault(vault.vaultId);
        ref.invalidate(vaultsProvider);
        ref.read(selectedVaultIdProvider.notifier).state = null;

      case _VaultAction.leaveVault:
        //Fake and not implemented will be done later
        return;

      case _VaultAction.createFolder:
        final name = await showAppInputDialog(
          context: context,
          title: 'Create Folder',
          label: 'Folder Name',
          hint: 'e.g. Weeknight Dinners',
          confirmLabel: 'Create',
          prefixIcon: Icons.folder_outlined,
        );
        if (name == null) return;
        await ref
            .read(vaultRepositoryProvider)
            .createFolder(vault.vaultId, name);
        ref.invalidate(vaultFoldersProvider(vault.vaultId));
    }
  }
}
