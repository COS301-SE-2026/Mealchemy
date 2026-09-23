import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/connectivity/offline_mutation_interceptor.dart';
import 'package:mealchemy/core/services/auth_interceptor.dart';
import 'package:mealchemy/features/admin/models/admin_models.dart';
import 'package:mealchemy/features/admin/repositories/api_admin_repository.dart';

Map<String, dynamic> _flagJson({String status = 'PENDING'}) => {
      'flagged_id': 12,
      'recipe_id': 87,
      'recipe_title': 'Spicy Chicken Ramen',
      'recipe_photo_url': null,
      'flagged_by_user_id': 4,
      'reason_value': 'SPAM_MISLEADING',
      'reason_label': 'Spam / misleading',
      'status': status,
      'flagged_at': '2026-09-19T13:00:00Z',
    };

Map<String, dynamic> _detailJson() => {
      ..._flagJson(),
      'recipeResponse': {
        'recipeId': 87,
        'ownerId': 9,
        'title': 'Spicy Chicken Ramen',
        'description': 'A warming bowl of ramen.',
        'cuisineType': 'JAPANESE',
        'prepTimeMins': 15,
        'cookingTimeMins': 20,
        'servingSize': 4,
        'photoUrl': null,
        'videoUrl': null,
        'externalUrl': null,
        'isCommunityPublished': true,
        'createdAt': '2026-09-18T10:00:00Z',
        'updatedAt': '2026-09-19T10:00:00Z',
        'parentRecipeId': null,
      },
    };

Map<String, dynamic> _userJson({bool admin = false}) => {
      'user_id': 4,
      'display_name': 'Jane Doe',
      'email': 'jane@example.com',
      'roles': admin ? ['USER', 'ADMIN'] : ['USER'],
    };

void main() {
  late Dio dio;
  late ApiAdminRepository repository;
  late List<RequestOptions> requests;
  late Object? responseData;
  late DioException? rejectedError;

  setUp(() {
    requests = [];
    responseData = [_flagJson()];
    rejectedError = null;

    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);

          final error = rejectedError;
          if (error != null) {
            handler.reject(error);
            return;
          }

          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: responseData,
            ),
          );
        },
      ),
    );

    repository = ApiAdminRepository(dio);
  });

  tearDown(() => dio.close(force: true));

  test('getFlags requests pending flags and maps snake_case fields', () async {
    final flags = await repository.getFlags();

    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/admin/flags');
    expect(requests.single.queryParameters, {'status': 'PENDING'});

    final flag = flags.single;
    expect(flag.flaggedId, 12);
    expect(flag.recipeId, 87);
    expect(flag.recipeTitle, 'Spicy Chicken Ramen');
    expect(flag.recipePhotoUrl, isNull);
    expect(flag.flaggedByUserId, 4);
    expect(flag.reasonValue, 'SPAM_MISLEADING');
    expect(flag.reasonLabel, 'Spam / misleading');
    expect(flag.status, FlagStatus.pending);
    expect(flag.flaggedAt, DateTime.utc(2026, 9, 19, 13));
  });

  for (final status in FlagStatus.values) {
    test('getFlags supports ${status.apiValue}', () async {
      responseData = [_flagJson(status: status.apiValue)];

      final flags = await repository.getFlags(status: status);

      expect(
        requests.single.queryParameters,
        {'status': status.apiValue},
      );
      expect(flags.single.status, status);
    });
  }

  test('getFlags preserves a successful empty queue', () async {
    responseData = [];

    expect(await repository.getFlags(), isEmpty);
  });

  test('unknown status is not silently treated as pending', () async {
    responseData = [_flagJson(status: 'UNKNOWN')];

    await expectLater(
      repository.getFlags(),
      throwsA(isA<FormatException>()),
    );
  });

  test('getFlagDetail maps the nested camelCase recipe', () async {
    responseData = _detailJson();

    final detail = await repository.getFlagDetail(12);

    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/admin/flags/12');
    expect(detail.flag.flaggedId, 12);
    expect(detail.recipe.recipeId, 87);
    expect(detail.recipe.ownerId, 9);
    expect(detail.recipe.title, 'Spicy Chicken Ramen');
    expect(detail.recipe.description, 'A warming bowl of ramen.');
    expect(detail.recipe.cuisineType, 'JAPANESE');
    expect(detail.recipe.prepTimeMins, 15);
    expect(detail.recipe.cookingTimeMins, 20);
    expect(detail.recipe.servingSize, 4);
    expect(detail.recipe.isCommunityPublished, isTrue);
    expect(detail.recipe.ingredients, isNull);
    expect(detail.recipe.steps, isNull);
  });

  test('dismissFlag sends a bodyless PUT and returns the updated flag',
      () async {
    responseData = _flagJson(status: 'REVIEWED');

    final flag = await repository.dismissFlag(12);

    expect(requests.single.method, 'PUT');
    expect(requests.single.path, '/admin/flags/12/dismiss');
    expect(requests.single.data, isNull);
    expect(flag.status, FlagStatus.reviewed);
  });

  test('removeFromCommunity sends DELETE and parses its response body',
      () async {
    responseData = _flagJson(status: 'REMOVED');

    final flag = await repository.removeFromCommunity(12);

    expect(requests.single.method, 'DELETE');
    expect(requests.single.path, '/admin/flags/12/recipe');
    expect(requests.single.data, isNull);
    expect(flag.status, FlagStatus.removed);
  });

  test('findUserByEmail trims email and maps the user summary', () async {
    responseData = _userJson();

    final user = await repository.findUserByEmail('  jane@example.com  ');

    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/admin/users');
    expect(
      requests.single.queryParameters,
      {'email': 'jane@example.com'},
    );
    expect(user.userId, 4);
    expect(user.displayName, 'Jane Doe');
    expect(user.email, 'jane@example.com');
    expect(user.roles, ['USER']);
    expect(user.isAdmin, isFalse);
  });

  test('findUserByEmail rejects blank email without making a request',
      () async {
    await expectLater(
      repository.findUserByEmail('   '),
      throwsArgumentError,
    );

    expect(requests, isEmpty);
  });

  test('promoteUser sends a bodyless PUT using the target user id', () async {
    responseData = _userJson(admin: true);

    final user = await repository.promoteUser(4);

    expect(requests.single.method, 'PUT');
    expect(requests.single.path, '/admin/users/4/promote');
    expect(requests.single.data, isNull);
    expect(user.roles, ['USER', 'ADMIN']);
    expect(user.isAdmin, isTrue);
  });

  final actions = <String, Future<Object?> Function(ApiAdminRepository)>{
    'queue': (repo) => repo.getFlags(),
    'detail': (repo) => repo.getFlagDetail(12),
    'dismiss': (repo) => repo.dismissFlag(12),
    'remove': (repo) => repo.removeFromCommunity(12),
    'lookup': (repo) => repo.findUserByEmail('jane@example.com'),
    'promote': (repo) => repo.promoteUser(4),
  };

  for (final action in actions.entries) {
    for (final status in [400, 401, 403, 404, 409, 500]) {
      test('${action.key} preserves HTTP $status and its error body', () async {
        final options = RequestOptions(path: '/test');
        final error = DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: status,
            data: {
              'status': status,
              'error': 'TEST_ERROR',
              'message': 'Backend explanation.',
              'timestamp': '2026-09-19T13:00:00Z',
            },
          ),
        );
        rejectedError = error;

        await expectLater(
          action.value(repository),
          throwsA(same(error)),
        );
      });
    }

    test('${action.key} preserves transport failures', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      rejectedError = error;

      await expectLater(
        action.value(repository),
        throwsA(same(error)),
      );
    });
  }

  test('uses authentication supplied by the injected Dio client', () async {
    final auth = AuthInterceptor()..setToken('test-token');
    dio.interceptors.insert(0, auth);

    await repository.getFlags();

    expect(
      requests.single.headers['Authorization'],
      'Bearer test-token',
    );
  });

  for (final status in [NetworkStatus.offline, NetworkStatus.checking]) {
    test('blocks all admin mutations while connectivity is ${status.name}',
        () async {
      dio.interceptors.insert(
        0,
        OfflineMutationInterceptor(() => status),
      );

      final mutations = <Future<Object?> Function()>[
        () => repository.dismissFlag(12),
        () => repository.removeFromCommunity(12),
        () => repository.promoteUser(4),
      ];

      for (final mutate in mutations) {
        await expectLater(
          mutate(),
          throwsA(
            isA<DioException>().having(
              (error) => error.error,
              'underlying error',
              isA<OfflineMutationException>(),
            ),
          ),
        );
      }

      expect(requests, isEmpty);
    });
  }
}
