import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/admin/models/admin_models.dart';
import 'package:mealchemy/features/admin/providers/admin_access_provider.dart';
import 'package:mealchemy/features/admin/repositories/admin_repository.dart';

AdminAccessContext _context({
  int? userId = 7,
  String? token = 'test-token',
  bool restoring = false,
  bool valid = true,
  NetworkStatus network = NetworkStatus.online,
}) =>
    (
      userId: userId,
      token: token,
      restoring: restoring,
      hasValidCredential: valid,
      network: network,
    );

class _AccessRepository implements AdminRepository {
  int calls = 0;
  Future<List<FlaggedRecipe>> Function() respond = () async => [];

  @override
  Future<List<FlaggedRecipe>> getFlags({
    FlagStatus status = FlagStatus.pending,
  }) {
    calls++;
    return respond();
  }

  @override
  Future<FlaggedRecipeDetail> getFlagDetail(int flaggedId) =>
      throw UnimplementedError();

  @override
  Future<FlaggedRecipe> dismissFlag(int flaggedId) =>
      throw UnimplementedError();

  @override
  Future<FlaggedRecipe> removeFromCommunity(int flaggedId) =>
      throw UnimplementedError();

  @override
  Future<AdminUserSummary> findUserByEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<AdminUserSummary> promoteUser(int userId) =>
      throw UnimplementedError();
}

DioException _httpError(int status) {
  final request = RequestOptions(path: '/admin/flags');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: status,
    ),
  );
}

void main() {
  late _AccessRepository repository;
  late StateProvider<AdminAccessContext> contextProvider;
  late ProviderContainer container;

  setUp(() {
    repository = _AccessRepository();
    contextProvider = StateProvider((ref) => _context());

    container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repository),
        adminAccessContextProvider.overrideWith(
          (ref) => ref.watch(contextProvider),
        ),
      ],
    );

    final subscription = container.listen(
      adminAccessStateProvider,
      (_, __) {},
      fireImmediately: true,
    );

    addTearDown(() {
      subscription.close();
      container.dispose();
    });
  });

  test('successful empty queue grants access', () async {
    expect(
      await container.read(adminAccessProvider.future),
      AdminAccess.allowed,
    );
    expect(repository.calls, 1);
  });

  final blockedContexts = <String, (AdminAccessContext, AdminAccess)>{
    'restoring session': (
      _context(restoring: true),
      AdminAccess.checking,
    ),
    'signed out': (
      _context(userId: null, token: null, valid: false),
      AdminAccess.signInRequired,
    ),
    'invalid credential': (
      _context(valid: false),
      AdminAccess.signInRequired,
    ),
    'missing token': (
      _context(token: null),
      AdminAccess.signInRequired,
    ),
    'offline': (
      _context(network: NetworkStatus.offline),
      AdminAccess.offline,
    ),
    'checking connectivity': (
      _context(network: NetworkStatus.checking),
      AdminAccess.checking,
    ),
  };

  for (final entry in blockedContexts.entries) {
    test('${entry.key} does not make another access request', () async {
      await container.read(adminAccessProvider.future);
      final callsBefore = repository.calls;

      container.read(contextProvider.notifier).state = entry.value.$1;

      expect(
        await container.read(adminAccessProvider.future),
        entry.value.$2,
      );
      expect(repository.calls, callsBefore);
    });
  }

  for (final entry in {
    401: AdminAccess.signInRequired,
    403: AdminAccess.forbidden,
    404: AdminAccess.signInRequired,
    500: AdminAccess.unavailable,
  }.entries) {
    test('HTTP ${entry.key} maps to ${entry.value.name}', () async {
      repository.respond = () async => throw _httpError(entry.key);
      container.invalidate(adminAccessProvider);

      expect(
        await container.read(adminAccessProvider.future),
        entry.value,
      );
    });
  }

  test('transport failure does not grant or deny admin permission', () async {
    repository.respond = () async => throw DioException(
          requestOptions: RequestOptions(path: '/admin/flags'),
          type: DioExceptionType.connectionTimeout,
        );
    container.invalidate(adminAccessProvider);

    expect(
      await container.read(adminAccessProvider.future),
      AdminAccess.unavailable,
    );
  });

  test('unexpected response failure does not grant access', () async {
    repository.respond =
        () async => throw const FormatException('Invalid response');
    container.invalidate(adminAccessProvider);

    expect(
      await container.read(adminAccessProvider.future),
      AdminAccess.unavailable,
    );
  });

  test('refresh hides previously allowed content until verification completes',
      () async {
    await container.read(adminAccessProvider.future);

    final pending = Completer<List<FlaggedRecipe>>();
    repository.respond = () => pending.future;
    container.invalidate(adminAccessProvider);

    expect(
      container.read(adminAccessStateProvider),
      AdminAccess.checking,
    );

    pending.complete([]);

    expect(
      await container.read(adminAccessProvider.future),
      AdminAccess.allowed,
    );
  });

  test('late success cannot restore access after logout', () async {
    final pending = Completer<List<FlaggedRecipe>>();
    repository.respond = () => pending.future;
    container.invalidate(adminAccessProvider);
    container.read(adminAccessStateProvider);

    container.read(contextProvider.notifier).state =
        _context(userId: null, token: null, valid: false);

    expect(
      await container.read(adminAccessProvider.future),
      AdminAccess.signInRequired,
    );

    pending.complete([]);
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(adminAccessStateProvider),
      AdminAccess.signInRequired,
    );
  });

  test('late success from previous user cannot grant access to next user',
      () async {
    final pending = Completer<List<FlaggedRecipe>>();
    repository.respond = () => pending.future;
    container.invalidate(adminAccessProvider);
    container.read(adminAccessStateProvider);

    repository.respond = () async => throw _httpError(403);
    container.read(contextProvider.notifier).state =
        _context(userId: 8, token: 'second-token');

    expect(
      await container.read(adminAccessProvider.future),
      AdminAccess.forbidden,
    );

    pending.complete([]);
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(adminAccessStateProvider),
      AdminAccess.forbidden,
    );
  });

  test('reconnection performs a fresh backend check', () async {
    await container.read(adminAccessProvider.future);

    container.read(contextProvider.notifier).state =
        _context(network: NetworkStatus.offline);
    await container.read(adminAccessProvider.future);
    final callsBefore = repository.calls;

    container.read(contextProvider.notifier).state = _context();

    expect(
      await container.read(adminAccessProvider.future),
      AdminAccess.allowed,
    );
    expect(repository.calls, callsBefore + 1);
  });

  test('new credential for the same user triggers another check', () async {
    await container.read(adminAccessProvider.future);
    final callsBefore = repository.calls;

    container.read(contextProvider.notifier).state =
        _context(token: 'renewed-token');

    await container.read(adminAccessProvider.future);

    expect(repository.calls, callsBefore + 1);
  });
}
