import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/vault_member.dart';
import '../providers/shared_vault_access_provider.dart';
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

  @override
  void initState() {
    super.initState();

    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (!mounted) return;
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
    ref.invalidate(sharedVaultAccessProvider(widget.vaultId));

    try {
      await ref.read(
        sharedVaultAccessProvider(widget.vaultId).future,
      );
    } catch (_) {
      // SharedVaultAccessView displays the current access/error state.
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _refresh,
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
                  const SizedBox(height: 24),
                  for (final member in access.members)
                    Card(
                      color: AppColors.surfaceWhite,
                      child: ListTile(
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
                            if (member.userId == access.currentMember.userId)
                              'You',
                          ].join(' · '),
                          style: AppTextStyles.bodySmall,
                        ),
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
