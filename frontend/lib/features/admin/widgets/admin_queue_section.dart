import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_chip.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/admin_models.dart';
import '../providers/admin_queue_provider.dart';
import 'admin_access_message.dart';
import 'admin_flag_card.dart';

class AdminQueueSection extends ConsumerWidget {
  const AdminQueueSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(adminQueueStatusProvider);
    final queue = ref.watch(adminQueueProvider(selected));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reported recipes',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final status in FlagStatus.values)
              Semantics(
                selected: selected == status,
                button: true,
                child: AppChip(
                  label: flagStatusLabel(status),
                  selected: selected == status,
                  onTap: () {
                    ref.read(adminQueueStatusProvider.notifier).state = status;
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        // Explicitly hide previous data during refresh/reload.
        if (queue.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 12),
                  Text('Loading reports…'),
                ],
              ),
            ),
          )
        else if (queue.hasError)
          _QueueError(
            error: queue.error!,
            onRetry: () => ref.invalidate(adminQueueProvider(selected)),
          )
        else
          _QueueResults(
            flags: queue.valueOrNull ?? const [],
            status: selected,
          ),
      ],
    );
  }
}

class _QueueError extends StatelessWidget {
  const _QueueError({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = error;
    if (failure is AdminQueueAccessException) {
      return AdminAccessMessage(access: failure.access);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          adminQueueErrorMessage(error),
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 12),
        AppButton.outlined(
          label: 'Retry reports',
          onPressed: onRetry,
        ),
      ],
    );
  }
}

class _QueueResults extends StatelessWidget {
  const _QueueResults({
    required this.flags,
    required this.status,
  });

  final List<FlaggedRecipe> flags;
  final FlagStatus status;

  @override
  Widget build(BuildContext context) {
    if (flags.isEmpty) {
      final message = switch (status) {
        FlagStatus.pending => 'No pending reports.',
        FlagStatus.reviewed => 'No reviewed reports.',
        FlagStatus.removed => 'No removed reports.',
      };

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(message, style: AppTextStyles.body),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${flags.length} ${flags.length == 1 ? 'report' : 'reports'}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        for (final flag in flags)
          Padding(
            key: ValueKey(flag.flaggedId),
            padding: const EdgeInsets.only(bottom: 12),
            child: AdminFlagCard(flag: flag),
          ),
      ],
    );
  }
}
