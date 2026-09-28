import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/shared_vault_access_provider.dart';

class SharedVaultAccessView extends ConsumerWidget {
  const SharedVaultAccessView({
    super.key,
    required this.vaultId,
    required this.builder,
  });

  final int vaultId;
  final Widget Function(SharedVaultAccess access) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(sharedVaultAccessProvider(vaultId));

    //check loading before using previous value during refresh
    if (access.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Checking vault access…',
                style: AppTextStyles.body,
              ),
            ),
          ],
        ),
      );
    }

    if (access.hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sharedVaultAccessMessage(access.error!),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              ref.invalidate(sharedVaultAccessProvider(vaultId));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Check again'),
          ),
        ],
      );
    }

    final value = access.valueOrNull;
    if (value == null) return const SizedBox.shrink();

    return builder(value);
  }
}
