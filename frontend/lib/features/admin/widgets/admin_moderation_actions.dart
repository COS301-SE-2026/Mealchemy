import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/Molecules/app_confirm_dialog.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/theme/app_typography.dart';
import '../models/admin_models.dart';
import '../providers/admin_access_provider.dart';
import '../providers/admin_moderation_provider.dart';

class AdminModerationActions extends ConsumerStatefulWidget {
  const AdminModerationActions({
    super.key,
    required this.flag,
  });

  final FlaggedRecipe flag;

  @override
  ConsumerState<AdminModerationActions> createState() =>
      _AdminModerationActionsState();
}

class _AdminModerationActionsState
    extends ConsumerState<AdminModerationActions> {
  bool _confirming = false;

  Future<void> _confirm(AdminModerationAction action) async {
    if (_confirming || !ref.read(adminModerationEnabledProvider)) return;

    final operation = ref.read(adminModerationProvider(widget.flag.flaggedId));
    if (operation.isSubmitting || operation.completed) return;

    final session = ref.read(adminAccessContextProvider);
    final flag = widget.flag;
    final removing = action == AdminModerationAction.remove;

    setState(() => _confirming = true);

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: removing ? 'Remove from community?' : 'Dismiss this report?',
      message: removing
          ? 'This recipe will no longer be published in the community. '
              'The author keeps it in their private vault. Pending reports '
              'for this recipe with the same reason will also be resolved.'
          : 'The recipe will remain published. Pending reports for this '
              'recipe with the same reason will also be resolved.',
      confirmLabel: removing ? 'Remove' : 'Dismiss',
      isDestructive: removing,
    );

    if (!mounted) return;

    setState(() => _confirming = false);
    if (confirmed != true) return;

    await ref.read(adminModerationProvider(flag.flaggedId).notifier).submit(
          flag: flag,
          action: action,
          confirmedSession: session,
        );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flag.status != FlagStatus.pending) {
      return const SizedBox.shrink();
    }

    final enabled = ref.watch(adminModerationEnabledProvider);
    final operation = ref.watch(adminModerationProvider(widget.flag.flaggedId));

    final canSubmit = enabled &&
        !_confirming &&
        !operation.isSubmitting &&
        !operation.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 28),
        Text('Moderation actions', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        if (!enabled) ...[
          Text(
            'An online connection and a valid admin session are required.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 12),
        ],
        AppButton.outlined(
          label: 'Dismiss report',
          isFullWidth: true,
          onPressed:
              canSubmit ? () => _confirm(AdminModerationAction.dismiss) : null,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Remove from community',
          isFullWidth: true,
          onPressed:
              canSubmit ? () => _confirm(AdminModerationAction.remove) : null,
        ),
      ],
    );
  }
}
