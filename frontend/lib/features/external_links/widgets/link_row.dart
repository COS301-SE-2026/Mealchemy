import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/feedback_provider.dart';
import '../../../core/shared_widgets/Molecules/app_confirm_dialog.dart';
import '../../../core/shared_widgets/atoms/app_toast.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/link.dart';
import '../providers/link_provider.dart';
import 'link_sheet.dart';

class LinkRow extends ConsumerWidget {
  const LinkRow({
    super.key,
    required this.link,
    this.mutationsEnabled = true,
  });

  final Link link;
  final bool mutationsEnabled;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete link',
      message: 'Remove "${link.name}" from your links?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed != true) return;
    final feedback = ref.read(feedbackProvider.notifier);
    try {
      await ref.read(linksProvider.notifier).removeLink(link.linkId);
      feedback.showShort(
        'Link deleted',
        kind: ToastKind.success,
        icon: Icons.delete_outline,
      );
    } catch (_) {
      feedback.showShort(
        'Could not delete the link. Try again.',
        kind: ToastKind.error,
        icon: Icons.error_outline,
      );
    }
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.link, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  link.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.tertiaryMuted,
                  ),
                ),
              ],
            ),
          ),
          if (mutationsEnabled) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.textMuted,
              onPressed: () => showLinkSheet(context: context, link: link),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.error,
              onPressed: () => _delete(context, ref),
            ),
          ],
        ],
      ),
    );
  }
}