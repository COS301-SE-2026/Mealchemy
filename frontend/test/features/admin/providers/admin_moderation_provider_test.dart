import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/admin/models/admin_models.dart';
import 'package:mealchemy/features/admin/providers/admin_access_provider.dart';
import 'package:mealchemy/features/admin/providers/admin_moderation_provider.dart';
import 'package:mealchemy/features/admin/repositories/admin_repository.dart';

AdminAccessContext _session({
  int userId = 7,
  NetworkStatus network = NetworkStatus.online,
}) =>
    (
      userId: userId,
      token: 'token-$userId',
      restoring: false,
      hasValidCredential: true,
      network: network,
    );

FlaggedRecipe _flag(FlagStatus status) => FlaggedRecipe(
      flaggedId: 12,
      recipeId: 87,
      recipeTitle: 'Ramen',
      flaggedByUserId: 4,
      reasonValue: 'SPAM_MISLEADING',
      reasonLabel: 'Spam / misleading',
      status: status,
      flaggedAt: DateTime.utc(2026, 9, 19),
    );

class _Repository implements AdminRepository {
  int dismissCalls = 0;
  int removeCalls = 0;
  Future<FlaggedRecipe> Function()? respond;

  @override
  Future<FlaggedRecipe> dismissFlag(int flaggedId) {
    dismissCalls++;
    return respond?.call() ?? Future.value(_flag(FlagStatus.reviewed));
  }

  @override
  Future<FlaggedRecipe> removeFromCommunity(int flaggedId) {
    removeCalls++;
    return respond?.call() ?? Future.value(_flag(FlagStatus.removed));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late ProviderContainer container;
  late _Repository repository;
  late StateProvider<AdminAccessContext> session;
  late List<(int, bool)> refreshes;

  setUp(() {
    repository = _Repository();
    session = StateProvider((ref) => _session());
    refreshes = [];

    container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repository),
        adminAccessContextProvider.overrideWith(
          (ref) => ref.watch(session),
        ),
        adminAccessStateProvider.overrideWith(
          (ref) => AdminAccess.allowed,
        ),
        adminModerationRefreshProvider.overrideWithValue(
          (recipeId, removed) => refreshes.add((recipeId, removed)),
        ),
      ],
    );

    final subscription = container.listen(
      adminModerationProvider(12),
      (_, __) {},
    );

    addTearDown(() {
      subscription.close();
      container.dispose();
    });
  });

  Future<void> submit(
    AdminModerationAction action, {
    FlagStatus status = FlagStatus.pending,
    AdminAccessContext? confirmedSession,
  }) {
    return container.read(adminModerationProvider(12).notifier).submit(
          flag: _flag(status),
          action: action,
          confirmedSession: confirmedSession ?? _session(),
        );
  }

  test('dismiss succeeds and refreshes moderation data', () async {
    await submit(AdminModerationAction.dismiss);

    expect(repository.dismissCalls, 1);
    expect(repository.removeCalls, 0);
    expect(refreshes, [(87, false)]);
    expect(container.read(adminModerationProvider(12)).completed, isTrue);
    expect(container.read(adminModerationProvider(12)).isError, isFalse);
  });

  test('removal requests community refresh', () async {
    await submit(AdminModerationAction.remove);

    expect(repository.removeCalls, 1);
    expect(refreshes, [(87, true)]);
    expect(
      container.read(adminModerationProvider(12)).message,
      contains('private vault'),
    );
  });

  test('duplicate submissions make one request', () async {
    final pending = Completer<FlaggedRecipe>();
    repository.respond = () => pending.future;

    final first = submit(AdminModerationAction.dismiss);
    await submit(AdminModerationAction.dismiss);

    expect(repository.dismissCalls, 1);
    expect(
      container.read(adminModerationProvider(12)).isSubmitting,
      isTrue,
    );

    pending.complete(_flag(FlagStatus.reviewed));
    await first;

    await submit(AdminModerationAction.dismiss);
    expect(repository.dismissCalls, 1);
  });

  for (final network in [NetworkStatus.offline, NetworkStatus.checking]) {
    test('blocks mutation when connectivity is ${network.name}', () async {
      container.read(session.notifier).state = _session(network: network);

      await submit(AdminModerationAction.remove);

      expect(repository.removeCalls, 0);
      expect(refreshes, isEmpty);
      expect(container.read(adminModerationProvider(12)).isError, isTrue);
    });
  }

  test('blocks confirmation from another session', () async {
    container.read(session.notifier).state = _session(userId: 8);

    await submit(
      AdminModerationAction.remove,
      confirmedSession: _session(userId: 7),
    );

    expect(repository.removeCalls, 0);
  });

  test('resolved report cannot be submitted', () async {
    await submit(
      AdminModerationAction.remove,
      status: FlagStatus.reviewed,
    );

    expect(repository.removeCalls, 0);
  });

  test('backend failure preserves its message and does not refresh', () async {
    final request = RequestOptions(path: '/admin/flags/12/dismiss');
    repository.respond = () async => throw DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: request,
            statusCode: 500,
            data: {'message': 'Please try again later.'},
          ),
        );

    await submit(AdminModerationAction.dismiss);

    final state = container.read(adminModerationProvider(12));
    expect(state.isSubmitting, isFalse);
    expect(state.completed, isFalse);
    expect(state.isError, isTrue);
    expect(state.message, 'Please try again later.');
    expect(refreshes, isEmpty);
  });

  test('late success does not update a different session', () async {
    final pending = Completer<FlaggedRecipe>();
    repository.respond = () => pending.future;

    final operation = submit(AdminModerationAction.remove);

    container.read(session.notifier).state = _session(userId: 8);
    container.read(adminModerationProvider(12));

    pending.complete(_flag(FlagStatus.removed));
    await operation;

    expect(refreshes, isEmpty);
    expect(container.read(adminModerationProvider(12)).completed, isFalse);
  });
}
