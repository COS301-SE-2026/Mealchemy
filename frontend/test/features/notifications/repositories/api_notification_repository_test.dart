import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/providers/api_service_provider.dart';
import 'package:mealchemy/core/services/auth_interceptor.dart';
import 'package:mealchemy/features/notifications/providers/notification_repository_provider.dart';
import 'package:mealchemy/features/notifications/repositories/api_notification_repository.dart';

Map<String, dynamic> _notificationJson({
  int id = 42,
  bool isRead = false,
}) =>
    {
      'notificationId': id,
      'type': 'RECIPE_ADDED',
      'message': 'Sofia added Pasta',
      'isRead': isRead,
      'actorUserId': 7,
      'refVaultId': 3,
      'refRecipeId': 118,
      'refInvitationId': null,
      'createdAt': '2026-09-26T14:03:12Z',
    };

void main() {
  late Dio dio;
  late ApiNotificationRepository repository;
  late List<RequestOptions> requests;
  late int status;
  Object? data;
  DioException? failure;

  setUp(() {
    requests = [];
    status = 200;
    data = null;
    failure = null;

    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);

          final error = failure;
          if (error != null) {
            handler.reject(error);
            return;
          }

          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: status,
              data: data,
            ),
          );
        },
      ),
    );

    repository = ApiNotificationRepository(dio);
  });

  tearDown(() => dio.close(force: true));

  test('requests a specific inbox page', () async {
    data = {
      'content': [_notificationJson()],
      'number': 1,
      'size': 10,
      'totalPages': 3,
      'totalElements': 21,
    };

    final page = await repository.getInbox(page: 1, size: 10);

    expect(page.content.single.notificationId, 42);
    expect(page.hasNext, isTrue);
    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/notifications');
    expect(requests.single.queryParameters, {'page': 1, 'size': 10});
  });

  test('accepts the documented nested page layout', () async {
    data = {
      'content': [],
      'page': {
        'number': 0,
        'size': 20,
        'totalPages': 0,
        'totalElements': 0,
      },
    };

    expect((await repository.getInbox()).content, isEmpty);
  });

  test('rejects a response for a different requested page', () async {
    data = {
      'content': [],
      'number': 1,
      'size': 20,
      'totalPages': 2,
      'totalElements': 21,
    };

    await expectLater(repository.getInbox(), throwsFormatException);
  });

  test('reads the bare unread count', () async {
    data = 5;

    expect(await repository.getUnreadCount(), 5);
    expect(requests.single.path, '/notifications/unread-count');
    expect(requests.single.method, 'GET');
  });

  for (final invalidCount in <Object?>[
    -1,
    '5',
    2.5,
    null,
    {'count': 5}
  ]) {
    test('rejects malformed unread count: $invalidCount', () async {
      data = invalidCount;
      await expectLater(repository.getUnreadCount(), throwsFormatException);
    });
  }

  test('marks one notification read with PATCH and no body', () async {
    data = _notificationJson(isRead: true);

    final notification = await repository.markAsRead(42);

    expect(notification.isRead, isTrue);
    expect(requests.single.method, 'PATCH');
    expect(requests.single.path, '/notifications/42/read');
    expect(requests.single.data, isNull);
  });

  test('rejects a mark-read response for another notification', () async {
    data = _notificationJson(id: 99, isRead: true);

    await expectLater(repository.markAsRead(42), throwsFormatException);
  });

  test('rejects a mark-read response that is still unread', () async {
    data = _notificationJson();

    await expectLater(repository.markAsRead(42), throwsFormatException);
  });

  test('mark-all-read accepts an empty 204 response', () async {
    status = 204;
    data = null;

    await repository.markAllAsRead();

    expect(requests.single.method, 'PATCH');
    expect(requests.single.path, '/notifications/read-all');
    expect(requests.single.data, isNull);
  });

  test('does not accept an unexpected mark-all-read status', () async {
    status = 200;

    await expectLater(repository.markAllAsRead(), throwsFormatException);
  });

  test('invalid arguments do not send requests', () async {
    await expectLater(
      repository.getInbox(page: -1),
      throwsArgumentError,
    );
    await expectLater(
      repository.getInbox(size: 0),
      throwsArgumentError,
    );
    await expectLater(
      repository.getInbox(size: 51),
      throwsArgumentError,
    );
    await expectLater(
      repository.markAsRead(0),
      throwsArgumentError,
    );

    expect(requests, isEmpty);
  });

  test('uses authentication from the injected Dio instance', () async {
    dio.interceptors.insert(
      0,
      AuthInterceptor()..setToken('test-token'),
    );
    data = 0;

    await repository.getUnreadCount();

    expect(
      requests.single.headers['Authorization'],
      'Bearer test-token',
    );
  });

  test('repository provider uses the shared Dio provider', () async {
    data = 3;

    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(dio),
      ],
    );
    addTearDown(container.dispose);

    final provided = container.read(notificationRepositoryProvider);

    expect(await provided.getUnreadCount(), 3);
    expect(requests.single.path, '/notifications/unread-count');
  });

  for (final code in [401, 404, 500]) {
    test('preserves HTTP $code errors', () async {
      final options = RequestOptions(path: '/notifications');
      failure = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: code,
          data: {'message': 'Backend explanation'},
        ),
      );

      await expectLater(repository.getInbox(), throwsA(same(failure)));
      await expectLater(repository.getUnreadCount(), throwsA(same(failure)));
      await expectLater(repository.markAsRead(42), throwsA(same(failure)));
      await expectLater(repository.markAllAsRead(), throwsA(same(failure)));
    });
  }

  test('preserves transport failures', () async {
    failure = DioException(
      requestOptions: RequestOptions(path: '/notifications'),
      type: DioExceptionType.connectionError,
    );

    await expectLater(repository.getInbox(), throwsA(same(failure)));
  });
}
