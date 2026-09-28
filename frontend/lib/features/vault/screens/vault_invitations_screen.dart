import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/shared_widgets/Molecules/app_confirm_dialog.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/vault_invitation.dart';
import '../providers/owner_vault_invitations_provider.dart';
import '../providers/shared_vault_access_provider.dart';
import '../widgets/shared_vault_access_view.dart';

class VaultInvitationsScreen extends ConsumerStatefulWidget {
  const VaultInvitationsScreen({
    super.key,
    required this.vaultId,
  });

  final int vaultId;

  @override
  ConsumerState<VaultInvitationsScreen> createState() =>
      _VaultInvitationsScreenState();
}

class _VaultInvitationsScreenState
    extends ConsumerState<VaultInvitationsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();

    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (!mounted) return;
        _invalidate();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _invalidate() {
    ref.invalidate(sharedVaultAccessProvider(widget.vaultId));
    ref.invalidate(ownerVaultInvitationsProvider(widget.vaultId));
  }

  Future<void> _refresh() async {
    if (ref
        .read(ownerVaultInvitationOperationProvider(widget.vaultId))
        .isBusy) {
      return;
    }

    _invalidate();

    try {
      await ref.read(
        ownerVaultInvitationsProvider(widget.vaultId).future,
      );
    } catch (_) {
      //access and history widgets display current error
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(vaultSessionProvider);
    final operation = ref.watch(
      ownerVaultInvitationOperationProvider(widget.vaultId),
    );

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Vault invitations'),
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
            tooltip: 'Refresh invitations',
            onPressed: operation.isBusy ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            SharedVaultAccessView(
              vaultId: widget.vaultId,
              builder: (access) {
                if (!access.canManageMembers) {
                  return Text(
                    'Only the vault owner can manage invitations.',
                    style: AppTextStyles.body,
                  );
                }

                return _InvitationForm(
                  key: ValueKey((widget.vaultId, session)),
                  vaultId: widget.vaultId,
                  vaultName: access.vault.name,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationForm extends ConsumerStatefulWidget {
  const _InvitationForm({
    super.key,
    required this.vaultId,
    required this.vaultName,
  });

  final int vaultId;
  final String vaultName;

  @override
  ConsumerState<_InvitationForm> createState() => _InvitationFormState();
}

class _InvitationFormState extends ConsumerState<_InvitationForm> {
  final _email = TextEditingController();
  bool _confirming = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final session = ref.read(vaultSessionProvider);
    final sent = await ref
        .read(ownerVaultInvitationOperationProvider(widget.vaultId).notifier)
        .send(
          email: _email.text,
          expectedSession: session,
        );

    if (!mounted || ref.read(vaultSessionProvider) != session) return;

    if (sent) _email.clear();
  }

  Future<void> _cancel(VaultInvitation invitation) async {
    if (_confirming ||
        ref
            .read(ownerVaultInvitationOperationProvider(widget.vaultId))
            .isBusy) {
      return;
    }

    final session = ref.read(vaultSessionProvider);
    setState(() => _confirming = true);

    try {
      final confirmed = await showAppConfirmDialog(
        context: context,
        title: 'Cancel invitation?',
        message: 'Cancel the invitation to ${invitation.invitedEmail}? '
            'They will no longer be able to accept it.',
        confirmLabel: 'Cancel invite',
        cancelLabel: 'Keep invite',
        isDestructive: true,
      );

      if (!mounted || confirmed != true) return;

      await ref
          .read(ownerVaultInvitationOperationProvider(widget.vaultId).notifier)
          .cancel(
            invitation: invitation,
            expectedSession: session,
          );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final operation = ref.watch(
      ownerVaultInvitationOperationProvider(widget.vaultId),
    );
    final enabled = ref.watch(
      ownerVaultInvitationsEnabledProvider(widget.vaultId),
    );
    final history = ref.watch(
      ownerVaultInvitationsProvider(widget.vaultId),
    );
    final busy = operation.isBusy || _confirming;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.vaultName,
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text('Invite a member', style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        Text(
          'Invite someone using their Mealchemy account email. '
          'They will join as a Viewer after accepting.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: _email,
          label: 'Email address',
          hint: 'chef@example.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          enabled: enabled && !busy,
          errorText: operation.emailError,
          onChanged: (_) {
            ref
                .read(
                  ownerVaultInvitationOperationProvider(widget.vaultId)
                      .notifier,
                )
                .clearFeedback();
          },
          onSubmitted: (_) {
            if (enabled && !busy) _send();
          },
        ),
        const SizedBox(height: 16),
        AppButton.primary(
          label: 'Send invitation',
          leftIcon: Icons.person_add_alt,
          isFullWidth: true,
          isLoading: operation.isSending,
          onPressed: enabled && !busy ? _send : null,
        ),
        if (operation.message != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              operation.message!,
              style: AppTextStyles.body.copyWith(
                color: operation.isError ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        Text('Invitation history', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        if (history.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (history.hasError) ...[
          Text(
            ownerInvitationErrorMessage(history.error!),
            style: AppTextStyles.body,
          ),
          TextButton(
            onPressed: busy
                ? null
                : () {
                    ref.invalidate(
                      ownerVaultInvitationsProvider(widget.vaultId),
                    );
                  },
            child: const Text('Retry invitations'),
          ),
        ] else if (history.requireValue.isEmpty)
          Text(
            'No invitations sent yet.',
            style: AppTextStyles.body,
          )
        else
          for (final invitation in history.requireValue)
            Card(
              color: AppColors.surfaceWhite,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.invitedEmail,
                      style: AppTextStyles.bodyBold,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vaultInvitationStatusLabel(invitation.status),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sent ${MaterialLocalizations.of(context).formatMediumDate(
                        invitation.createdAt.toLocal(),
                      )}',
                      style: AppTextStyles.caption,
                    ),
                    if (invitation.respondedAt != null)
                      Text(
                        'Updated ${MaterialLocalizations.of(context).formatMediumDate(
                          invitation.respondedAt!.toLocal(),
                        )}',
                        style: AppTextStyles.caption,
                      ),
                    if (invitation.isPending) ...[
                      const SizedBox(height: 12),
                      AppButton.outlined(
                        label: 'Cancel invitation',
                        isFullWidth: true,
                        isLoading:
                            operation.cancellingId == invitation.invitationId,
                        onPressed:
                            enabled && !busy ? () => _cancel(invitation) : null,
                      ),
                    ],
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
