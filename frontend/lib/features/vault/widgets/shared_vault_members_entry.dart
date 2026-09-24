import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/shared_vault_access_provider.dart';
import '../providers/vault_provider.dart';
import 'shared_vault_access_view.dart';

class SharedVaultMembersEntry extends ConsumerStatefulWidget {
  const SharedVaultMembersEntry({
    super.key,
    required this.vaultId,
  });

  final int vaultId;

  @override
  ConsumerState<SharedVaultMembersEntry> createState() =>
      _SharedVaultMembersEntryState();
}

class _SharedVaultMembersEntryState
    extends ConsumerState<SharedVaultMembersEntry> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();

    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (!mounted) return;
        _refreshAccess();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _refreshAccess() {
    ref.invalidate(sharedVaultAccessProvider(widget.vaultId));
    ref.invalidate(vaultMembersProvider(widget.vaultId));
    ref.invalidate(vaultsProvider);
  }

  Future<void> _openMembers() async {
    final vaultId = widget.vaultId;
    final session = ref.read(vaultSessionProvider);

    // Recheck access when opening the route, even if the entry already
    // displayed a successful result.
    ref.invalidate(sharedVaultAccessProvider(vaultId));

    await context.push(
      AppRoutes.vaultMembers.replaceFirst(':vaultId', '$vaultId'),
    );

    if (!mounted || ref.read(vaultSessionProvider) != session) return;

    // Account for role changes or removal while another screen was open.
    _refreshAccess();
  }

  @override
  Widget build(BuildContext context) {
    return SharedVaultAccessView(
      vaultId: widget.vaultId,
      builder: (access) => Card(
        color: AppColors.surfaceWhite,
        child: ListTile(
          leading: const Icon(
            Icons.people_outline,
            color: AppColors.primary,
          ),
          title: Text(
            'Members',
            style: AppTextStyles.bodyBold,
          ),
          subtitle: Text(
            'Your role: ${vaultRoleLabel(access.role)}',
            style: AppTextStyles.bodySmall,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _openMembers,
        ),
      ),
    );
  }
}
