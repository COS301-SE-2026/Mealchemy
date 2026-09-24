import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/Molecules/app_confirm_dialog.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/vault_invitation.dart';
import '../providers/incoming_vault_invitations_provider.dart';
import '../providers/shared_vault_access_provider.dart';
import '../providers/vault_provider.dart';

class IncomingVaultInvitationsScreen extends ConsumerStatefulWidget {
  const IncomingVaultInvitationsScreen({super.key});

  @override
  ConsumerState<IncomingVaultInvitationsScreen> createState() =>
      _IncomingVaultInvitationsScreenState();
}

class _IncomingVaultInvitationsScreenState
    extends ConsumerState<IncomingVaultInvitationsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();

    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (!mounted) return;
        _refresh();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (ref.read(incomingVaultInvitationOperationProvider).isBusy) return;

    ref.invalidate(incomingVaultInvitationsProvider);

    try {
      await ref.read(incomingVaultInvitationsProvider.future);
    } catch (_) {
      //body displays access or loading error
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(vaultSessionProvider);
    final operation = ref.watch(incomingVaultInvitationOperationProvider);
    final unavailable = ref.watch(incomingInvitationsUnavailableProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Incoming invitations'),
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
            if (unavailable != null)
              Text(unavailable, style: AppTextStyles.body)
            else
              _IncomingInvitationsBody(
                key: ValueKey(session),
              ),
          ],
        ),
      ),
    );
  }
}

class _IncomingInvitationsBody extends ConsumerStatefulWidget {
  const _IncomingInvitationsBody({super.key});

  @override
  ConsumerState<_IncomingInvitationsBody> createState() =>
      _IncomingInvitationsBodyState();
}

class _IncomingInvitationsBodyState
    extends ConsumerState<_IncomingInvitationsBody> {
  bool _confirming = false;

  Future<void> _accept(VaultInvitation invitation) async {
    await ref.read(incomingVaultInvitationOperationProvider.notifier).respond(
          invitation: invitation,
          accept: true,
          expectedSession: ref.read(vaultSessionProvider),
        );
  }

  Future<void> _decline(VaultInvitation invitation) async {
    if (_confirming ||
        ref.read(incomingVaultInvitationOperationProvider).isBusy) {
      return;
    }

    final session = ref.read(vaultSessionProvider);
    setState(() => _confirming = true);

    try {
      final confirmed = await showAppConfirmDialog(
        context: context,
        title: 'Decline invitation?',
        message: 'Decline the invitation to ${invitation.vaultName}? '
            'You will not join this vault.',
        confirmLabel: 'Decline',
        cancelLabel: 'Keep invite',
      );

      if (!mounted || confirmed != true) return;

      await ref.read(incomingVaultInvitationOperationProvider.notifier).respond(
            invitation: invitation,
            accept: false,
            expectedSession: session,
          );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  void _openVault(int vaultId) {
    if (ref.read(incomingInvitationsUnavailableProvider) != null) return;

    ref.read(isSharedModeProvider.notifier).state = true;
    ref.read(selectedVaultIdProvider.notifier).state = vaultId;
    ref.read(vaultSearchQueryProvider.notifier).state = '';
    ref.invalidate(vaultsProvider);

    context.go(AppRoutes.vault);
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(incomingVaultInvitationsProvider);
    final operation = ref.watch(incomingVaultInvitationOperationProvider);
    final busy = operation.isBusy || _confirming;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Cook together',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Accept an invitation to join a shared vault as a Viewer. '
          'The owner can change your role afterwards.',
          style: AppTextStyles.body,
        ),
        if (operation.message != null) ...[
          const SizedBox(height: 20),
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
        if (operation.joinedVaultId != null) ...[
          const SizedBox(height: 12),
          AppButton.outlined(
            label: 'Open vault',
            leftIcon: Icons.folder_open,
            isFullWidth: true,
            onPressed: busy ? null : () => _openVault(operation.joinedVaultId!),
          ),
        ],
        const SizedBox(height: 24),
        if (history.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (history.hasError) ...[
          Text(
            incomingInvitationErrorMessage(history.error!),
            style: AppTextStyles.body,
          ),
          TextButton(
            onPressed: busy
                ? null
                : () => ref.invalidate(incomingVaultInvitationsProvider),
            child: const Text('Retry invitations'),
          ),
        ] else if (history.requireValue.isEmpty)
          Text(
            'No pending invitations.',
            style: AppTextStyles.body,
          )
        else
          for (final invitation in history.requireValue)
            Card(
              color: AppColors.surfaceWhite,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      invitation.vaultName,
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Invited by ${invitation.invitedByEmail}',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sent ${MaterialLocalizations.of(context).formatMediumDate(
                        invitation.createdAt.toLocal(),
                      )}',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 16),
                    AppButton.primary(
                      label: 'Accept invitation',
                      isFullWidth: true,
                      isLoading:
                          operation.invitationId == invitation.invitationId &&
                              operation.isAccepting,
                      onPressed: busy ? null : () => _accept(invitation),
                    ),
                    const SizedBox(height: 10),
                    AppButton.outlined(
                      label: 'Decline invitation',
                      isFullWidth: true,
                      isLoading:
                          operation.invitationId == invitation.invitationId &&
                              !operation.isAccepting,
                      onPressed: busy ? null : () => _decline(invitation),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
