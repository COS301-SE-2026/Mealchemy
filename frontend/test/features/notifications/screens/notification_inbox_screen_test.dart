import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/notifications/models/notification_page.dart';
import 'package:mealchemy/features/notifications/models/vault_notification.dart';
import 'package:mealchemy/features/notifications/providers/notification_destination_provider.dart';
import 'package:mealchemy/features/notifications/providers/notification_repository_provider.dart';
import 'package:mealchemy/features/notifications/repositories/mock_notification_repository.dart';
import 'package:mealchemy/features/notifications/screens/notification_inbox_screen.dart';
import 'package:mealchemy/features/notifications/widgets/notification_bell.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';

VaultNotification _item(
  int id, {
  String type = 'RECIPE_EDITED',
}) {
  return VaultNotification(
    notificationId: id,
    rawType: type,
    message: 'Notification $id',
    isRead: false,
    createdAt: DateTime.utc(2026, 9, 27).add(Duration(minutes: id)),
    actorUserId: 7,
    refVaultId: 3,
    refRecipeId: 118,
    refInvitationId: 9,
  );
}

class _Repository extends MockNotificationRepository {
  _Repository(Iterable<VaultNotification> notifications)
      : super(notifications: notifications);

  bool failLoad = false;
  bool failRead = false;
  Completer<NotificationPage>? pendingPage;
  final List<int> readIds = [];

  @override
  Future<NotificationPage> getInbox({
    int page = 0,
    int size = 20,
  }) async {
    if (failLoad) throw Exception('Unavailable');

    final pending = pendingPage;
    if (pending != null) return pending.future;

    return super.getInbox(page: page, size: size);
  }

  @override
  Future<VaultNotification> markAsRead(int notificationId) async {
    readIds.add(notificationId);
    if (failRead) throw Exception('Read failed');
    return super.markAsRead(notificationId);
  }
}

class _Resolver extends Fake implements NotificationDestinationResolver {
  NotificationDestination destination = const NotificationDestination(
    location: '/recipe/118?vaultId=3',
  );
  String? failure;
  int calls = 0;

  @override
  Future<NotificationDestination?> resolve(
    VaultNotification notification,
  ) async {
    calls++;
    if (failure != null) {
      throw NotificationDestinationException(failure!);
    }
    return destination;
  }
}

Future<ProviderContainer> _host(
  WidgetTester tester, {
  required _Repository repository,
  _Resolver? resolver,
  bool signedIn = true,
  bool startAtHome = false,
  bool settle = true,
}) async {
  final container = ProviderContainer(
    overrides: [
      vaultSessionProvider.overrideWithValue((
        userId: signedIn ? 1 : null,
        token: signedIn ? 'test-token' : null,
        restoring: false,
        hasValidCredential: signedIn,
      )),
      vaultConnectionProvider.overrideWithValue(NetworkStatus.online),
      notificationRepositoryProvider.overrideWithValue(repository),
      notificationDestinationResolverProvider.overrideWithValue(
        resolver ?? _Resolver(),
      ),
      vaultsProvider.overrideWith((ref) async => [
            Vault(
              vaultId: 3,
              ownerId: 1,
              vaultType: VaultTypes.shared,
              name: 'Family',
              createdAt: DateTime.utc(2026),
            ),
          ]),
    ],
  );

  final router = GoRouter(
    initialLocation: startAtHome ? '/home' : AppRoutes.notifications,
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(
          body: NotificationBell(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationInboxScreen(),
      ),
      GoRoute(
        path: '/recipe/:id',
        builder: (context, state) => Scaffold(
          body: Text('Opened recipe ${state.pathParameters['id']}'),
        ),
      ),
      GoRoute(
        path: AppRoutes.vault,
        builder: (context, state) => const Scaffold(
          body: Text('Opened vault'),
        ),
      ),
      GoRoute(
        path: AppRoutes.incomingVaultInvitations,
        builder: (context, state) => const Scaffold(
          body: Text('Opened invitations'),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const Scaffold(
          body: Text('Dashboard'),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const Scaffold(
          body: Text('Login'),
        ),
      ),
    ],
  );

  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    container.dispose();
  });

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );

  if (settle) await tester.pumpAndSettle();

  return container;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('signed-out users cannot view the inbox', (tester) async {
    await _host(
      tester,
      repository: _Repository([_item(1)]),
      signedIn: false,
    );

    expect(
      find.text('Sign in to view your notifications.'),
      findsOneWidget,
    );
    expect(find.text('Notification 1'), findsNothing);
  });

  testWidgets('empty inbox has an empty state', (tester) async {
    await _host(tester, repository: _Repository([]));

    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('shows loading while the inbox request is pending',
      (tester) async {
    final pending = Completer<NotificationPage>();
    final repository = _Repository([])..pendingPage = pending;

    await _host(
      tester,
      repository: repository,
      settle: false,
    );
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    pending.complete(
      NotificationPage(
        content: [],
        number: 0,
        size: 20,
        totalPages: 0,
        totalElements: 0,
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('failed inbox request can be retried', (tester) async {
    final repository = _Repository([_item(1)])..failLoad = true;

    await _host(tester, repository: repository);

    expect(find.text('Try again'), findsOneWidget);

    repository.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Notification 1'), findsOneWidget);
  });

  testWidgets('bell shows unread count and opens the inbox', (tester) async {
    await _host(
      tester,
      repository: _Repository([_item(1), _item(2)]),
      startAtHome: true,
    );

    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.notifications_none_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Your shared vault activity'), findsOneWidget);
    expect(find.text('Notification 1'), findsOneWidget);
  });

  testWidgets('opening a notification marks it read before navigation',
      (tester) async {
    final repository = _Repository([_item(1)]);
    final resolver = _Resolver();

    await _host(
      tester,
      repository: repository,
      resolver: resolver,
    );

    await tester.tap(find.text('Notification 1'));
    await tester.pumpAndSettle();

    expect(repository.readIds, [1]);
    expect(resolver.calls, 1);
    expect(find.text('Opened recipe 118'), findsOneWidget);
  });

  testWidgets('failed mark-read does not navigate', (tester) async {
    final repository = _Repository([_item(1)])..failRead = true;
    final resolver = _Resolver();

    await _host(
      tester,
      repository: repository,
      resolver: resolver,
    );

    await tester.tap(find.text('Notification 1'));
    await tester.pumpAndSettle();

    expect(resolver.calls, 0);
    expect(find.text('Unread'), findsOneWidget);
    expect(find.textContaining('Could not update read status'), findsOneWidget);
  });

  testWidgets('informational notifications can be marked read without opening',
      (tester) async {
    final repository = _Repository([
      _item(1, type: 'MEMBER_REMOVED'),
    ]);
    final resolver = _Resolver();

    await _host(
      tester,
      repository: repository,
      resolver: resolver,
    );

    await tester.tap(find.text('Notification 1'));
    await tester.pumpAndSettle();
    expect(resolver.calls, 0);
    expect(repository.readIds, isEmpty);

    await tester.tap(find.byTooltip('Mark notification as read'));
    await tester.pumpAndSettle();

    expect(repository.readIds, [1]);
    expect(find.text('Unread'), findsNothing);
    expect(resolver.calls, 0);
  });

  testWidgets('lost access shows a friendly message in the inbox',
      (tester) async {
    final resolver = _Resolver()
      ..failure = 'You no longer have access to this vault.';

    await _host(
      tester,
      repository: _Repository([_item(1)]),
      resolver: resolver,
    );

    await tester.tap(find.text('Notification 1'));
    await tester.pumpAndSettle();

    expect(
      find.text('You no longer have access to this vault.'),
      findsOneWidget,
    );
    expect(find.text('Your shared vault activity'), findsOneWidget);
  });

  testWidgets('vault navigation selects the referenced shared vault',
      (tester) async {
    final resolver = _Resolver()
      ..destination = const NotificationDestination(
        location: AppRoutes.vault,
        selectedVaultId: 3,
      );

    final container = await _host(
      tester,
      repository: _Repository([_item(1, type: 'RECIPE_REMOVED')]),
      resolver: resolver,
    );

    await tester.tap(find.text('Notification 1'));
    await tester.pumpAndSettle();

    expect(find.text('Opened vault'), findsOneWidget);
    expect(container.read(isSharedModeProvider), isTrue);
    expect(container.read(selectedVaultIdProvider), 3);
  });

  testWidgets('mark-all-read updates the visible inbox', (tester) async {
    await _host(
      tester,
      repository: _Repository([_item(1), _item(2)]),
    );

    expect(find.text('Unread'), findsNWidgets(2));

    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();

    expect(find.text('Unread'), findsNothing);
  });

  testWidgets('load more retrieves the next page', (tester) async {
    await _host(
      tester,
      repository: _Repository(
        List.generate(21, (index) => _item(index + 1)),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Load more'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Notification 1'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Notification 1'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });
}
