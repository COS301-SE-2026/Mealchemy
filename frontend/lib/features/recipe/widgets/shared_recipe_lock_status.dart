import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../vault/providers/shared_vault_access_provider.dart';
import '../providers/shared_recipe_lock_provider.dart';

class SharedRecipeLockStatus extends ConsumerStatefulWidget {
  const SharedRecipeLockStatus({
    super.key,
    required this.target,
  });

  final SharedRecipeLockTarget target;

  @override
  ConsumerState<SharedRecipeLockStatus> createState() =>
      _SharedRecipeLockStatusState();
}

class _SharedRecipeLockStatusState extends ConsumerState<SharedRecipeLockStatus>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      ref.invalidate(sharedRecipeLockProvider(widget.target));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sharedRecipeLockProvider(widget.target));
    final userId = ref.watch(vaultSessionProvider).userId;

    String? message;

    if (state.isLoading) {
      message = 'Checking editing availability…';
    } else if (state.hasError) {
      message = 'Editing availability could not be checked.';
    } else {
      final lock = state.valueOrNull;
      if (lock != null && !lock.isHeldBy(userId ?? -1)) {
        message = 'Being edited by ${lock.lockedByEmail}.';
      }
    }

    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline,
            size: 18,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          if (state.hasError)
            TextButton(
              onPressed: () {
                ref.invalidate(sharedRecipeLockProvider(widget.target));
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
