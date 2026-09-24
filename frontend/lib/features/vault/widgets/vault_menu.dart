import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_confirm_dialog.dart';
import '../providers/vault_folder_management_provider.dart';
import 'vault_folder_actions.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/shared_vault_access_provider.dart';
import '../providers/owner_vault_invitations_provider.dart';
import '../providers/vault_repository_provider.dart';
import '../models/vault.dart';
import '../providers/vault_provider.dart';

enum _VaultAction { createFolder, inviteMember, deleteVault, leaveVault }

class VaultMenuButton extends ConsumerWidget {
  const VaultMenuButton({super.key, required this.vault});

  final Vault vault;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(vaultSessionProvider);
    final isShared = vault.vaultType == VaultTypes.shared;
    final canManageFolders = ref.watch(
      canManageVaultFoldersProvider(vault),
    );
    final foldersEnabled = ref.watch(
      vaultFolderManagementEnabledProvider(vault),
    );
    final online = ref.watch(vaultConnectionProvider) == NetworkStatus.online;
    final busy = ref.watch(
      vaultFolderManagementProvider(vault.vaultId),
    );

    final access =
        isShared ? ref.watch(sharedVaultAccessProvider(vault.vaultId)) : null;

    final verifiedSharedAccess = access != null &&
        !access.isLoading &&
        !access.hasError &&
        access.valueOrNull != null;

    final isOwner = isShared
        ? verifiedSharedAccess && access.valueOrNull?.canManageMembers == true
        : canManageFolders && vault.ownerId == session.userId;

    final enabled =
        online && !busy && (isShared ? verifiedSharedAccess : canManageFolders);

    return PopupMenuButton<_VaultAction>(
      icon: const Icon(Icons.more_vert, color: AppColors.primary),
      color: AppColors.bgLight,
      elevation: 4,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabled: enabled,
      tooltip: enabled ? 'Vault actions' : 'Vault changes unavailable',
      onSelected: (action) => _handle(context, ref, action),
      itemBuilder: (_) => [
        if (canManageFolders)
          PopupMenuItem<_VaultAction>(
            value: _VaultAction.createFolder,
            enabled: foldersEnabled,
            child: _row(
              Icons.create_new_folder_outlined,
              'Create folder',
            ),
          ),
        if (isShared && isOwner) ...[
          PopupMenuItem<_VaultAction>(
            value: _VaultAction.inviteMember,
            child: _row(Icons.person_add_alt, 'Invite member'),
          ),
          PopupMenuItem<_VaultAction>(
            value: _VaultAction.deleteVault,
            child: _row(
              Icons.delete_forever_outlined,
              'Delete vault',
              destructive: true,
            ),
          ),
        ],
        if (isShared && !isOwner)
          PopupMenuItem<_VaultAction>(
            value: _VaultAction.leaveVault,
            enabled: false,
            child: _row(Icons.logout, 'Leave vault (coming soon)'),
          ),
      ],
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
      case _VaultAction.inviteMember:
        ref.invalidate(sharedVaultAccessProvider(vault.vaultId));
        ref.invalidate(ownerVaultInvitationsProvider(vault.vaultId));

        await context.push(
          AppRoutes.vaultInvitations.replaceFirst(
            ':vaultId',
            '${vault.vaultId}',
          ),
        );
        return;
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
        await showVaultFolderAction(
          context: context,
          ref: ref,
          vault: vault,
          action: VaultFolderAction.create,
        );
        return;
    }
  }
}
