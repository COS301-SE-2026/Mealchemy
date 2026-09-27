import 'vault_notification.dart';

class NotificationInboxState {
  NotificationInboxState({
    List<VaultNotification> items = const [],
    this.unreadCount,
    this.countNeedsRefresh = true,
    this.hasLoadedInbox = false,
    this.hasMore = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.isRefreshingCount = false,
    this.isMarkingAll = false,
    this.markingReadId,
    this.inboxError,
    this.countError,
    this.actionError,
  }) : items = List.unmodifiable(items);

  final List<VaultNotification> items;

  //null means the server count has not been established yet
  //never infer the total unread count from one loaded page
  final int? unreadCount;
  final bool countNeedsRefresh;

  final bool hasLoadedInbox;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool isRefreshingCount;
  final bool isMarkingAll;
  final int? markingReadId;

  final String? inboxError;
  final String? countError;
  final String? actionError;

  bool get isChangingReadStatus => isMarkingAll || markingReadId != null;
}
