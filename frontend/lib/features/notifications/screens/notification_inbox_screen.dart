import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/Molecules/app_refresh.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../recipe/providers/recipe_provider.dart';
import '../../vault/providers/incoming_vault_invitations_provider.dart';
import '../../vault/providers/shared_vault_access_provider.dart';
import '../../vault/providers/vault_provider.dart';
import '../models/vault_notification.dart';
import '../providers/notification_destination_provider.dart';
import '../providers/notification_inbox_provider.dart';

class NotificationInboxScreen extends ConsumerWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(vaultSessionProvider);

    final signedIn = !session.restoring &&
        session.hasValidCredential &&
        session.userId != null &&
        session.token != null;

    if (!signedIn) {
      return Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: AppBar(title: const Text('Notifications')),
        body: Center(
          child: session.restoring
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Sign in to view your notifications.'),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
        ),
      );
    }

    // Recreate screen-local operations when the account/token changes.
    return _InboxBody(key: ValueKey(session));
  }
}

class _InboxBody extends ConsumerStatefulWidget {
  const _InboxBody({super.key});

  @override
  ConsumerState<_InboxBody> createState() => _InboxBodyState();
}

class _InboxBodyState extends ConsumerState<_InboxBody> {
  int? _openingId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_refresh());
    });
  }

  Future<void> _refresh() async {
    if (_openingId != null ||
        ref.read(notificationInboxProvider).isChangingReadStatus) {
      return;
    }

    await ref.read(notificationInboxProvider.notifier).refresh();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _open(VaultNotification notification) async {
    if (_openingId != null ||
        ref.read(notificationInboxProvider).isChangingReadStatus) {
      return;
    }

    final session = ref.read(vaultSessionProvider);
    setState(() => _openingId = notification.notificationId);

    try {
      final marked = await ref
          .read(notificationInboxProvider.notifier)
          .markAsRead(notification.notificationId);

      if (!mounted || ref.read(vaultSessionProvider) != session) return;
      if (!marked) return;

      final destination = await ref
          .read(notificationDestinationResolverProvider)
          .resolve(notification);

      if (!mounted || ref.read(vaultSessionProvider) != session) return;
      if (destination == null) return;

      final vaultId = destination.selectedVaultId;

      if (vaultId != null) {
        //refresh selectable vaults before selecting target
        //otherwise old cached list could display wrong vault
        ref.invalidate(vaultsProvider);
        final vaults = await ref.read(vaultsProvider.future);

        if (!mounted || ref.read(vaultSessionProvider) != session) return;

        if (!vaults.any((vault) => vault.vaultId == vaultId)) {
          throw const NotificationDestinationException(
            'This vault is no longer available in your vault list.',
          );
        }

        ref.read(isSharedModeProvider.notifier).state = true;
        ref.read(selectedVaultIdProvider.notifier).state = vaultId;
        ref.read(vaultSearchQueryProvider.notifier).state = '';

        ref.invalidate(vaultFoldersProvider(vaultId));
        ref.invalidate(sharedVaultAccessProvider(vaultId));
      } else if (notification.type == VaultNotificationType.vaultInvite) {
        ref.invalidate(incomingVaultInvitationsProvider);
      } else if (notification.refRecipeId != null) {
        ref.invalidate(recipeByIdProvider(notification.refRecipeId!));
        ref.invalidate(recipeDetailProvider(notification.refRecipeId!));
      }

      if (!mounted || ref.read(vaultSessionProvider) != session) return;

      await context.push<void>(destination.location);
    } on NotificationDestinationException catch (error) {
      if (mounted && ref.read(vaultSessionProvider) == session) {
        _showMessage(error.message);
      }
    } catch (_) {
      if (mounted && ref.read(vaultSessionProvider) == session) {
        _showMessage(
          'Could not open this notification. Refresh and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  Future<void> _markRead(int id) async {
    await ref.read(notificationInboxProvider.notifier).markAsRead(id);
  }

  Future<void> _markAll() async {
    await ref.read(notificationInboxProvider.notifier).markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(notificationInboxProvider);
    final online = ref.watch(vaultConnectionProvider) == NetworkStatus.online;
    final busy = _openingId != null || inbox.isChangingReadStatus;
    final hasUnread =
        (inbox.unreadCount ?? 0) > 0 || inbox.items.any((item) => !item.isRead);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        title: const Text('Notifications'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh notifications',
            onPressed: online && !busy && !inbox.isRefreshing ? _refresh : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: AppRefresh(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text(
                'Your shared vault activity',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Invitations, recipe updates, and changes across your vaults.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: online && !busy && hasUnread ? _markAll : null,
                  icon: const Icon(Icons.done_all),
                  label: Text(
                    inbox.isMarkingAll ? 'Updating…' : 'Mark all read',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
              if (!online)
                const _Notice(
                  message: 'You’re offline. Reconnect to refresh '
                      'notifications or update read status.',
                ),
              if (inbox.countError != null) _Notice(message: inbox.countError!),
              if (inbox.inboxError != null) ...[
                _Notice(message: inbox.inboxError!),
                TextButton(
                  onPressed: online && !busy ? _refresh : null,
                  child: const Text('Try again'),
                ),
              ],
              if (inbox.actionError != null)
                _Notice(message: inbox.actionError!),
              if (inbox.isRefreshing)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              if (!inbox.hasLoadedInbox &&
                  !inbox.isRefreshing &&
                  inbox.inboxError == null)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (inbox.hasLoadedInbox &&
                  inbox.items.isEmpty &&
                  !inbox.isRefreshing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Shared vault activity will appear here.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              for (final notification in inbox.items)
                _NotificationCard(
                  key: ValueKey(notification.notificationId),
                  notification: notification,
                  opening: _openingId == notification.notificationId,
                  onOpen: online && !busy && notificationCanOpen(notification)
                      ? () => _open(notification)
                      : null,
                  onMarkRead: online && !busy && !notification.isRead
                      ? () => _markRead(notification.notificationId)
                      : null,
                ),
              if (inbox.hasMore) ...[
                const SizedBox(height: 16),
                if (inbox.isLoadingMore)
                  const Center(child: CircularProgressIndicator())
                else
                  OutlinedButton(
                    onPressed: online && !busy && !inbox.isRefreshing
                        ? () => ref
                            .read(notificationInboxProvider.notifier)
                            .loadMore()
                        : null,
                    child: const Text('Load more'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    super.key,
    required this.notification,
    required this.opening,
    this.onOpen,
    this.onMarkRead,
  });

  final VaultNotification notification;
  final bool opening;
  final VoidCallback? onOpen;
  final VoidCallback? onMarkRead;

  @override
  Widget build(BuildContext context) {
    final localTime = notification.createdAt.toLocal();
    final localization = MaterialLocalizations.of(context);
    final timestamp = '${localization.formatMediumDate(localTime)} · '
        '${localization.formatTimeOfDay(TimeOfDay.fromDateTime(localTime))}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: notification.isRead
            ? AppColors.surfaceLight
            : AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: notification.isRead
                ? AppColors.divider
                : AppColors.accent.withValues(alpha: 0.6),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  notification.isRead
                      ? Icons.notifications_none_outlined
                      : Icons.notifications_active_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textLight,
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timestamp,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Unread',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (opening)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (!notification.isRead)
                  IconButton(
                    tooltip: 'Mark notification as read',
                    onPressed: onMarkRead,
                    icon: const Icon(Icons.done),
                    color: AppColors.primary,
                  )
                else if (notificationCanOpen(notification))
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}
