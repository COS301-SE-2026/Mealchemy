import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/Molecules/app_confirm_dialog.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/vault_member.dart';
import '../providers/owner_vault_invitations_provider.dart';
import '../providers/shared_vault_access_provider.dart';
import '../providers/vault_member_management_provider.dart';
import '../widgets/shared_vault_access_view.dart';

class VaultMembersScreen extends ConsumerStatefulWidget {
  const VaultMembersScreen({
    super.key,
    required this.vaultId,
  });

  final int vaultId;

  @override
  ConsumerState<VaultMembersScreen> createState() => _VaultMembersScreenState();
}

class _VaultMembersScreenState extends ConsumerState<VaultMembersScreen> {
  late final AppLifecycleListener _lifecycle;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();

    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (!mounted) return;

        //if a confirmation is open, this invalidates stale permissions
        //notifier checks the refreshed state before submitting
        ref.invalidate(sharedVaultAccessProvider(widget.vaultId));
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (ref.read(vaultMemberManagementProvider(widget.vaultId)).isBusy) {
      return;
    }

    ref.invalidate(sharedVaultAccessProvider(widget.vaultId));

    try {
      await ref.read(sharedVaultAccessProvider(widget.vaultId).future);
    } catch (_) {
      //SharedVaultAccessView displays current error
    }
  }

  Future<void> _confirm(
    VaultMember member,
    VaultMemberAction action,
  ) async {
    if (_confirming ||
        ref.read(vaultMemberManagementProvider(widget.vaultId)).isBusy ||
        !ref.read(vaultMemberManagementEnabledProvider(widget.vaultId))) {
      return;
    }

    final session = ref.read(vaultSessionProvider);
    final removing = action == VaultMemberAction.remove;

    final message = switch (action) {
      VaultMemberAction.makeEditor =>
        'Make ${member.email} an Editor? They will be able to create, '
            'rename, and delete folders in this shared vault.',
      VaultMemberAction.makeViewer =>
        'Make ${member.email} a Viewer? They will still be able to view '
            'this vault, but will no longer be able to manage its folders.',
      VaultMemberAction.remove =>
        'Remove ${member.email} from this shared vault? '
            'This removes their membership, not their account or recipes.',
    };

    setState(() => _confirming = true);

    try {
      final confirmed = await showAppConfirmDialog(
        context: context,
        title: removing ? 'Remove member?' : 'Change member role?',
        message: message,
        confirmLabel: removing ? 'Remove' : 'Change role',
        cancelLabel: 'Cancel',
        isDestructive: removing,
      );

      if (!mounted || confirmed != true) return;

      await ref
          .read(vaultMemberManagementProvider(widget.vaultId).notifier)
          .submit(
            member: member,
            action: action,
            expectedSession: session,
          );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final operation = ref.watch(
      vaultMemberManagementProvider(widget.vaultId),
    );
    final enabled = ref.watch(
      vaultMemberManagementEnabledProvider(widget.vaultId),
    );
    final busy = operation.isBusy || _confirming;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Vault members'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.vault);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh members',
            icon: const Icon(Icons.refresh),
            onPressed: busy ? null : _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            if (operation.isBusy) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
            ],
            if (operation.message != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  operation.message!,
                  style: AppTextStyles.body.copyWith(
                    color:
                        operation.isError ? AppColors.error : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            SharedVaultAccessView(
              vaultId: widget.vaultId,
              builder: (access) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    access.vault.name,
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your role: ${vaultRoleLabel(access.role)}',
                    style: AppTextStyles.bodyBold,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _roleDescription(access.role),
                    style: AppTextStyles.body,
                  ),
                  if (access.canManageMembers) ...[
                    const SizedBox(height: 20),
                    AppButton.outlined(
                      label: 'Invitations',
                      leftIcon: Icons.mail_outline,
                      isFullWidth: true,
                      onPressed: busy
                          ? null
                          : () {
                              ref.invalidate(
                                sharedVaultAccessProvider(widget.vaultId),
                              );
                              ref.invalidate(
                                ownerVaultInvitationsProvider(widget.vaultId),
                              );

                              context.push(
                                AppRoutes.vaultInvitations.replaceFirst(
                                  ':vaultId',
                                  '${widget.vaultId}',
                                ),
                              );
                            },
                    ),
                  ],
                  const SizedBox(height: 24),
                  for (final member in access.members)
                    Card(
                      color: AppColors.surfaceWhite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            leading: Icon(
                              member.isOwner
                                  ? Icons.workspace_premium_outlined
                                  : Icons.person_outline,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              member.email,
                              style: AppTextStyles.bodyBold,
                            ),
                            subtitle: Text(
                              [
                                vaultRoleLabel(member.role),
                                if (member.userId ==
                                    access.currentMember.userId)
                                  'You',
                              ].join(' · '),
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                          if (access.canManageMembers &&
                              !member.isOwner &&
                              member.id != null &&
                              member.userId != access.vault.ownerId)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  TextButton.icon(
                                    onPressed: enabled && !busy
                                        ? () => _confirm(
                                              member,
                                              member.role ==
                                                      VaultMemberRole.viewer
                                                  ? VaultMemberAction.makeEditor
                                                  : VaultMemberAction
                                                      .makeViewer,
                                            )
                                        : null,
                                    icon: const Icon(Icons.manage_accounts),
                                    label: Text(
                                      member.role == VaultMemberRole.viewer
                                          ? 'Make Editor'
                                          : 'Make Viewer',
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: enabled && !busy
                                        ? () => _confirm(
                                              member,
                                              VaultMemberAction.remove,
                                            )
                                        : null,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                    ),
                                    icon: const Icon(
                                        Icons.person_remove_outlined),
                                    label: const Text('Remove member'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleDescription(VaultMemberRole role) {
    return switch (role) {
      VaultMemberRole.owner =>
        'You own this vault and can manage its members and folders.',
      VaultMemberRole.editor =>
        'You can view this vault and manage its folders.',
      VaultMemberRole.viewer =>
        'You can view this vault. Only the owner can change your role.',
    };
  }
}
