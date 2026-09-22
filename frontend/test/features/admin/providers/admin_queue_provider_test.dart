import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/admin/models/admin_models.dart';
import 'package:mealchemy/features/admin/providers/admin_access_provider.dart';
import 'package:mealchemy/features/admin/providers/admin_queue_provider.dart';
import 'package:mealchemy/features/admin/repositories/admin_repository.dart';

AdminAccessContext _context(int id) => (
      userId: id,
      token: 'token-$id',
      restoring: false,
      hasValidCredential: true,
      network: NetworkStatus.online,
    );

FlaggedRecipe _flag(int id, FlagStatus status) => FlaggedRecipe(
      flaggedId: id,
      recipeId: 87,
      recipeTitle: 'Recipe $id',
      flaggedByUserId: 4,
      reasonValue: 'SPAM_MISLEADING',
      reasonLabel: 'Spam / misleading',
      status: status,
      flaggedAt: DateTime.utc(2026, 9, 19, 13),
    );

class _Repository implements AdminRepository {
  final calls = <FlagStatus>[];
  Future<List<FlaggedRecipe>> Function(FlagStatus) respond =
      (status) async => [];

  @override
  Future<List<FlaggedRecipe>> getFlags({
    FlagStatus status = FlagStatus.pending,
  }) {
    calls.add(status);
    return respond(status);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

DioException _error(int status) {
  final request = RequestOptions(path: '/admin/flags');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: status,
      data: {'message': 'Backend explanation.'},
    ),
  );
}

void main() {
  late _Repository repository;
  late ProviderContainer container;
  late StateProvider<AdminAccessContext> session;
  late StateProvider<AdminAccess> access;

  setUp(() {
    repository = _Repository();
    session = StateProvider((ref) => _context(7));
    access = StateProvider((ref) => AdminAccess.allowed);

    container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repository),
        adminAccessContextProvider.overrideWith(
          (ref) => ref.watch(session),
        ),
        adminAccessStateProvider.overrideWith(
          (ref) => ref.watch(access),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  void keepQueue(FlagStatus status) {
    final subscription = container.listen(
      adminQueueProvider(status),
      (_, __) {},
    );
    addTearDown(subscription.close);
  }

  for (final status in FlagStatus.values) {
    test('requests ${status.apiValue}', () async {
      repository.respond = (value) async => [_flag(12, value)];
      keepQueue(status);

      final result = await container.read(adminQueueProvider(status).future);

      expect(repository.calls, [status]);
      expect(result.single.status, status);
    });
  }

  test('does not fetch when access is forbidden', () async {
    container.read(access.notifier).state = AdminAccess.forbidden;
    keepQueue(FlagStatus.pending);

    await expectLater(
      container.read(adminQueueProvider(FlagStatus.pending).future),
      throwsA(
        isA<AdminQueueAccessException>().having(
          (error) => error.access,
          'access',
          AdminAccess.forbidden,
        ),
      ),
    );
    expect(repository.calls, isEmpty);
  });

  for (final entry in {
    401: AdminAccess.signInRequired,
    403: AdminAccess.forbidden,
    404: AdminAccess.signInRequired,
  }.entries) {
    test('maps HTTP ${entry.key} to an access failure', () async {
      repository.respond = (_) async => throw _error(entry.key);
      keepQueue(FlagStatus.pending);

      await expectLater(
        container.read(adminQueueProvider(FlagStatus.pending).future),
        throwsA(
          isA<AdminQueueAccessException>().having(
            (error) => error.access,
            'access',
            entry.value,
          ),
        ),
      );
    });
  }

  test('preserves server failure and its display message', () async {
    final failure = _error(500);
    repository.respond = (_) async => throw failure;
    keepQueue(FlagStatus.pending);

    await expectLater(
      container.read(adminQueueProvider(FlagStatus.pending).future),
      throwsA(same(failure)),
    );
    expect(adminQueueErrorMessage(failure), 'Backend explanation.');
  });

  test('late pending result does not replace reviewed results', () async {
    final pending = Completer<List<FlaggedRecipe>>();
    repository.respond = (status) => status == FlagStatus.pending
        ? pending.future
        : Future.value([_flag(20, status)]);

    keepQueue(FlagStatus.pending);
    keepQueue(FlagStatus.reviewed);

    await container.read(adminQueueProvider(FlagStatus.reviewed).future);
    pending.complete([_flag(12, FlagStatus.pending)]);
    await container.read(adminQueueProvider(FlagStatus.pending).future);

    final reviewed =
        container.read(adminQueueProvider(FlagStatus.reviewed)).requireValue;
    expect(reviewed.single.flaggedId, 20);
  });

  test('session change discards a late response from the previous user',
      () async {
    final pending = Completer<List<FlaggedRecipe>>();
    repository.respond = (_) => pending.future;
    keepQueue(FlagStatus.pending);

    // Start the first session's request.
    container.read(adminQueueProvider(FlagStatus.pending));
    expect(repository.calls, hasLength(1));

    repository.respond = (status) async => [_flag(99, status)];
    container.read(session.notifier).state = _context(8);

    final current =
        await container.read(adminQueueProvider(FlagStatus.pending).future);
    expect(current.single.flaggedId, 99);

    pending.complete([_flag(12, FlagStatus.pending)]);
    await Future<void>.delayed(Duration.zero);

    expect(
      container
          .read(adminQueueProvider(FlagStatus.pending))
          .requireValue
          .single
          .flaggedId,
      99,
    );
  });

  test('refresh fetches new results', () async {
    var id = 12;
    repository.respond = (status) async => [_flag(id, status)];
    keepQueue(FlagStatus.pending);

    await container.read(adminQueueProvider(FlagStatus.pending).future);
    id = 13;

    final refreshed = await container.refresh(
      adminQueueProvider(FlagStatus.pending).future,
    );

    expect(repository.calls, hasLength(2));
    expect(refreshed.single.flaggedId, 13);
  });
}
