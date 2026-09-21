import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/admin/models/admin_models.dart';
import 'package:mealchemy/features/admin/providers/admin_access_provider.dart';
import 'package:mealchemy/features/admin/providers/admin_users_provider.dart';
import 'package:mealchemy/features/admin/repositories/admin_repository.dart';

AdminAccessContext _session({
  int id = 7,
  NetworkStatus network = NetworkStatus.online,
}) =>
    (
      userId: id,
      token: 'token-$id',
      restoring: false,
      hasValidCredential: true,
      network: network,
    );

AdminUserSummary _user({bool admin = false}) => AdminUserSummary(
      userId: 4,
      displayName: 'Jane Doe',
      email: 'jane@example.com',
      roles: admin ? ['USER', 'ADMIN'] : ['USER'],
    );

DioException _error(int status) {
  final request = RequestOptions(path: '/admin/users');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: status,
    ),
  );
}

class _Repository implements AdminRepository {
  final searches = <String>[];
  final promotions = <int>[];

  Future<AdminUserSummary> Function(String) lookup = (_) async => _user();
  Future<AdminUserSummary> Function(int) promote =
      (_) async => _user(admin: true);

  @override
  Future<AdminUserSummary> findUserByEmail(String email) {
    searches.add(email);
    return lookup(email);
  }

  @override
  Future<AdminUserSummary> promoteUser(int userId) {
    promotions.add(userId);
    return promote(userId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late ProviderContainer container;
  late _Repository repository;
  late StateProvider<AdminAccessContext> session;

  setUp(() {
    repository = _Repository();
    session = StateProvider((ref) => _session());

    container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repository),
        adminAccessContextProvider.overrideWith(
          (ref) => ref.watch(session),
        ),
        adminAccessStateProvider.overrideWith(
          (ref) => AdminAccess.allowed,
        ),
      ],
    );

    final subscription = container.listen(adminUsersProvider, (_, __) {});
    addTearDown(() {
      subscription.close();
      container.dispose();
    });
  });

  AdminUsersNotifier notifier() => container.read(adminUsersProvider.notifier);

  Future<void> search() async {
    notifier().changeEmail('  jane@example.com  ');
    await notifier().search();
  }

  Future<void> promote() => notifier().promote(
        confirmedUser: _user(),
        confirmedSession: _session(),
      );

  test('trims the email and displays the returned user', () async {
    await search();

    expect(repository.searches, ['jane@example.com']);
    expect(container.read(adminUsersProvider).user?.userId, 4);
  });

  test('invalid email does not reach the repository', () async {
    notifier().changeEmail('invalid');
    await notifier().search();

    expect(repository.searches, isEmpty);
    expect(container.read(adminUsersProvider).emailError, isNotNull);
  });

  test('changing email clears the previous selection immediately', () async {
    await search();

    notifier().changeEmail('someone@example.com');

    expect(container.read(adminUsersProvider).user, isNull);
  });

  test('late lookup does not restore a result after email changes', () async {
    final pending = Completer<AdminUserSummary>();
    repository.lookup = (_) => pending.future;

    notifier().changeEmail('jane@example.com');
    final request = notifier().search();

    notifier().changeEmail('someone@example.com');
    pending.complete(_user());
    await request;

    expect(container.read(adminUsersProvider).user, isNull);
    expect(
      container.read(adminUsersProvider).email,
      'someone@example.com',
    );
  });

  test('promotes using the selected user id and updates roles', () async {
    await search();
    await promote();

    expect(repository.promotions, [4]);
    expect(container.read(adminUsersProvider).user?.isAdmin, isTrue);
    expect(
      container.read(adminUsersProvider).message,
      'Jane Doe is now an administrator.',
    );
  });

  test('duplicate submissions make only one promotion request', () async {
    await search();

    final pending = Completer<AdminUserSummary>();
    repository.promote = (_) => pending.future;

    final first = promote();
    await promote();
    expect(repository.promotions, [4]);

    pending.complete(_user(admin: true));
    await first;
    await promote();

    expect(repository.promotions, [4]);
  });

  test('already-admin lookup cannot be promoted', () async {
    repository.lookup = (_) async => _user(admin: true);
    await search();
    await promote();

    expect(repository.promotions, isEmpty);
  });

  for (final network in [NetworkStatus.offline, NetworkStatus.checking]) {
    test('blocks lookup and promotion when ${network.name}', () async {
      await search();
      container.read(session.notifier).state = _session(network: network);

      await promote();
      expect(repository.promotions, isEmpty);

      final previousSearches = repository.searches.length;
      notifier().changeEmail('jane@example.com');
      await notifier().search();

      expect(repository.searches, hasLength(previousSearches));
    });
  }

  test('404 lookup shows no-match message', () async {
    repository.lookup = (_) async => throw _error(404);
    await search();

    expect(container.read(adminUsersProvider).user, isNull);
    expect(
      container.read(adminUsersProvider).message,
      'No user was found with that email address.',
    );
  });

  test('409 promotion clears selection and explains existing admin role',
      () async {
    await search();
    repository.promote = (_) async => throw _error(409);

    await promote();

    expect(container.read(adminUsersProvider).user, isNull);
    expect(container.read(adminUsersProvider).isPromoting, isFalse);
    expect(
      container.read(adminUsersProvider).message,
      contains('already an administrator'),
    );
  });

  test('server failure does not report promotion success', () async {
    await search();
    repository.promote = (_) async => throw _error(500);

    await promote();

    expect(container.read(adminUsersProvider).isError, isTrue);
    expect(container.read(adminUsersProvider).user, isNull);
  });

  test('confirmation from an old session cannot promote a user', () async {
    await search();

    container.read(session.notifier).state = _session(id: 8);
    await search();
    await promote();

    expect(repository.promotions, isEmpty);
  });

  test('late promotion result cannot populate a different session', () async {
    await search();

    final pending = Completer<AdminUserSummary>();
    repository.promote = (_) => pending.future;
    final request = promote();

    container.read(session.notifier).state = _session(id: 8);
    container.read(adminUsersProvider);

    pending.complete(_user(admin: true));
    await request;

    expect(container.read(adminUsersProvider).user, isNull);
    expect(container.read(adminUsersProvider).message, isNull);
  });
}
