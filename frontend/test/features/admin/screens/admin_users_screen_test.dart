import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/routes/app_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/admin/models/admin_models.dart';
import 'package:mealchemy/features/admin/providers/admin_access_provider.dart';
import 'package:mealchemy/features/admin/providers/admin_queue_provider.dart';
import 'package:mealchemy/features/admin/repositories/admin_repository.dart';
import 'package:mealchemy/features/admin/screens/admin_users_screen.dart';

const _session = (
  userId: 7,
  token: 'test-token',
  restoring: false,
  hasValidCredential: true,
  network: NetworkStatus.online,
);

class _Repository implements AdminRepository {
  int promotions = 0;
  bool alreadyAdmin = false;

  AdminUserSummary user(bool admin) => AdminUserSummary(
        userId: 4,
        displayName: 'Jane Doe',
        email: 'jane@example.com',
        roles: admin ? ['USER', 'ADMIN'] : ['USER'],
      );

  @override
  Future<AdminUserSummary> findUserByEmail(String email) async =>
      user(alreadyAdmin);

  @override
  Future<AdminUserSummary> promoteUser(int userId) async {
    promotions++;
    return user(true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Widget _host(
  _Repository repository, {
  AdminAccess access = AdminAccess.allowed,
}) =>
    ProviderScope(
      overrides: [
        adminAccessContextProvider.overrideWithValue(_session),
        adminAccessProvider.overrideWith((ref) async => access),
        adminRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: AdminUsersScreen()),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> findUser(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), 'jane@example.com');
    await tester.tap(find.text('Find user'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Jane Doe'));
  }

  testWidgets('invalid email shows field validation', (tester) async {
    await tester.pumpWidget(_host(_Repository()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'invalid');
    await tester.tap(find.text('Find user'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('cancel confirmation does not promote', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(_host(repository));
    await tester.pumpAndSettle();
    await findUser(tester);

    await tester.ensureVisible(find.text('Promote to admin'));
    await tester.tap(find.text('Promote to admin'));
    await tester.pumpAndSettle();

    expect(find.text('Promote to administrator?'), findsOneWidget);
    expect(repository.promotions, 0);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.promotions, 0);
  });

  testWidgets('confirmation promotes and removes the promotion button',
      (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(_host(repository));
    await tester.pumpAndSettle();
    await findUser(tester);

    await tester.ensureVisible(find.text('Promote to admin'));
    await tester.tap(find.text('Promote to admin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Promote'));
    await tester.pumpAndSettle();

    expect(repository.promotions, 1);
    expect(find.text('Roles: USER, ADMIN'), findsOneWidget);
    expect(find.text('Promote to admin'), findsNothing);
  });

  testWidgets('existing admin has no promotion button', (tester) async {
    final repository = _Repository()..alreadyAdmin = true;
    await tester.pumpWidget(_host(repository));
    await tester.pumpAndSettle();
    await findUser(tester);

    expect(find.text('Promote to admin'), findsNothing);
    expect(
      find.text('This user is already an administrator.'),
      findsOneWidget,
    );
  });

  testWidgets('changing email removes the result', (tester) async {
    await tester.pumpWidget(_host(_Repository()));
    await tester.pumpAndSettle();
    await findUser(tester);

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'other@example.com');
    await tester.pump();

    expect(find.text('Jane Doe'), findsNothing);
    expect(find.text('Promote to admin'), findsNothing);
  });

  testWidgets('forbidden direct route does not show the lookup form',
      (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.adminUsers,
      routes: appRouter.configuration.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminAccessContextProvider.overrideWithValue(_session),
          adminAccessProvider.overrideWith(
            (ref) async => AdminAccess.forbidden,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AdminUsersScreen), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(
      find.text('Your account does not have administrator access.'),
      findsOneWidget,
    );
  });

  testWidgets('Manage admins opens the real management route', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.admin,
      routes: appRouter.configuration.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminAccessContextProvider.overrideWithValue(_session),
          adminAccessProvider.overrideWith(
            (ref) async => AdminAccess.allowed,
          ),
          adminQueueProvider.overrideWith((ref, status) async => []),
          adminRepositoryProvider.overrideWithValue(_Repository()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manage admins'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminUsersScreen), findsOneWidget);
    expect(find.text('Find user'), findsOneWidget);
  });
}
