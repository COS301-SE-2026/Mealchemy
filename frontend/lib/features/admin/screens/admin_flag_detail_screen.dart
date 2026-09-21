import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/Molecules/app_refresh.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/admin_access_provider.dart';
import '../providers/admin_flag_detail_provider.dart';
import '../widgets/admin_access_message.dart';
import '../widgets/admin_flag_review_content.dart';
import '../widgets/admin_moderation_actions.dart';
import '../providers/admin_moderation_provider.dart';

class AdminFlagDetailScreen extends ConsumerWidget {
  const AdminFlagDetailScreen({
    super.key,
    required this.flaggedId,
  });

  final int flaggedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(adminAccessStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Report #$flaggedId'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.admin);
            }
          },
        ),
      ),
      body: SafeArea(
        child: access == AdminAccess.allowed
            ? _ReviewBody(flaggedId: flaggedId)
            : Padding(
                padding: const EdgeInsets.all(20),
                child: AdminAccessMessage(access: access),
              ),
      ),
    );
  }
}

class _ReviewBody extends ConsumerWidget {
  const _ReviewBody({required this.flaggedId});

  final int flaggedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = adminFlagDetailProvider(flaggedId);
    final review = ref.watch(provider);
    final operation = ref.watch(adminModerationProvider(flaggedId));

    void retry() => ref.invalidate(provider);

    final Widget content;

    if (review.isLoading) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading report…'),
            ],
          ),
        ),
      );
    } else if (review.hasError) {
      final error = review.error!;

      content = error is AdminDetailAccessException
          ? AdminAccessMessage(access: error.access)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adminDetailErrorMessage(error),
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 12),
                AppButton.outlined(
                  label: 'Retry report',
                  onPressed: retry,
                ),
              ],
            );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminFlagReviewContent(
            review: review.requireValue,
            onRetry: retry,
          ),
          AdminModerationActions(
            flag: review.requireValue.detail.flag,
          ),
        ],
      );
    }

    return AppRefresh(
      onRefresh: () async {
        if (operation.isSubmitting) return;
        ref.invalidate(provider);
        try {
          await ref.read(provider.future);
        } catch (_) {
          //screen renders error
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          if (operation.isSubmitting) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
            const Text('Submitting moderation action…'),
            const SizedBox(height: 20),
          ],
          if (operation.message != null) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                operation.message!,
                style: AppTextStyles.bodyBold.copyWith(
                  color: operation.isError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          content,
        ],
      ),
    );
  }
}
