import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/connectivity/offline_mutation_interceptor.dart';
import 'package:mealchemy/core/services/auth_interceptor.dart';
import 'package:mealchemy/features/vault/models/vault_invitation.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/repositories/api_vault_repository.dart';

Map<String, dynamic> _member({
  String role = 'VIEWER',
  int? id = 12,
}) =>
    {
      'id': id,
      'vaultId': 5,
      'userId': 7,
      'email': 'sofia@example.com',
      'joinedAt': '2026-09-21T10:05:00Z',
      'role': role,
    };

Map<String, dynamic> _invite({String status = 'PENDING'}) => {
      'invitationId': 12,
      'vaultId': 5,
      'vaultName': 'Flat 3B Meals',
      'invitedEmail': 'sofia@example.com',
      'invitedByEmail': 'gabriela@example.com',
      'status': status,
      'createdAt': '2026-09-21T10:00:00Z',
      'expiresAt': '2026-09-28T10:00:00Z',
      'respondedAt': status == 'PENDING' ? null : '2026-09-22T10:00:00Z',
    };

void main() {
  late Dio dio;
  late ApiVaultRepository repository;
  late List<RequestOptions> requests;
  late Object? data;
  late int status;
  DioException? failure;

  setUp(() {
    requests = [];
    data = [];
    status = 200;
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

    repository = ApiVaultRepository(dio);
  });

  tearDown(() => dio.close(force: true));

  test('lists accessible vaults rather than only owned vaults', () async {
    data = [
      {
        'vaultId': 5,
        'ownerId': 99,
        'vaultType': 'SHARED',
        'name': 'Joined vault',
        'createdAt': '2026-09-21T10:00:00Z',
      },
    ];

    final vaults = await repository.getMyVaults();

    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/vaults/accessible');
    expect(vaults.single.ownerId, 99);
  });

  test('member list includes owner and regular member', () async {
    data = [
      _member(role: 'OWNER', id: null),
      {..._member(), 'userId': 8},
    ];

    final members = await repository.getMembers(5);

    expect(requests.single.path, '/vault/5/members/all');
    expect(members.first.isOwner, isTrue);
    expect(members.first.id, isNull);
    expect(members.last.role, VaultMemberRole.viewer);
  });

  test('removes by user ID with no request body', () async {
    status = 204;
    data = null;

    await repository.removeMember(5, 7);

    expect(requests.single.method, 'DELETE');
    expect(requests.single.path, '/vault/5/members/7');
    expect(requests.single.data, isNull);
  });

  test('changes role using PATCH and parses updated member', () async {
    data = _member(role: 'EDITOR');

    final member = await repository.changeMemberRole(
      5,
      7,
      VaultMemberRole.editor,
    );

    expect(requests.single.method, 'PATCH');
    expect(requests.single.path, '/vault/5/members/7/role');
    expect(requests.single.data, {'role': 'EDITOR'});
    expect(member.role, VaultMemberRole.editor);
  });

  test('rejects assigning OWNER without a request', () async {
    await expectLater(
      repository.changeMemberRole(5, 7, VaultMemberRole.owner),
      throwsArgumentError,
    );

    expect(requests, isEmpty);
  });

  test('creates invitation using trimmed email', () async {
    data = _invite();

    final invitation = await repository.createInvitation(
      5,
      '  sofia@example.com  ',
    );

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/vault/5/invitations');
    expect(requests.single.data, {'email': 'sofia@example.com'});
    expect(invitation.status, VaultInvitationStatus.pending);
  });

  test('rejects blank invitation email without a request', () async {
    await expectLater(
      repository.createInvitation(5, '   '),
      throwsArgumentError,
    );

    expect(requests, isEmpty);
  });

  test('owner invitation list preserves non-pending statuses', () async {
    data = [
      _invite(),
      {..._invite(status: 'CANCELLED'), 'invitationId': 13},
    ];

    final invitations = await repository.getVaultInvitations(5);

    expect(requests.single.path, '/vault/5/invitations');
    expect(invitations, hasLength(2));
    expect(invitations.last.status, VaultInvitationStatus.cancelled);
  });

  test('loads incoming invitations', () async {
    data = [_invite()];

    final invitations = await repository.getMyInvitations();

    expect(requests.single.path, '/invitations/me');
    expect(invitations.single.invitedByEmail, 'gabriela@example.com');
  });

  test('accepts invitation with bodyless POST and returns Viewer', () async {
    data = _member();

    final member = await repository.acceptInvitation(12);

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/invitations/12/accept');
    expect(requests.single.data, isNull);
    expect(member.role, VaultMemberRole.viewer);
  });

  test('declines invitation with bodyless POST', () async {
    data = _invite(status: 'DECLINED');

    final invitation = await repository.declineInvitation(12);

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/invitations/12/decline');
    expect(requests.single.data, isNull);
    expect(invitation.status, VaultInvitationStatus.declined);
  });

  test('cancels invitation and accepts empty 204 response', () async {
    status = 204;
    data = null;

    await repository.cancelInvitation(12);

    expect(requests.single.method, 'DELETE');
    expect(requests.single.path, '/invitations/12');
    expect(requests.single.data, isNull);
  });

  test('uses authentication supplied by shared Dio', () async {
    dio.interceptors.insert(
      0,
      AuthInterceptor()..setToken('test-token'),
    );

    await repository.getMyInvitations();

    expect(
      requests.single.headers['Authorization'],
      'Bearer test-token',
    );
  });

  final mutations = <String, Future<Object?> Function(ApiVaultRepository)>{
    'invite': (repo) => repo.createInvitation(5, 'sofia@example.com'),
    'accept': (repo) => repo.acceptInvitation(12),
    'decline': (repo) => repo.declineInvitation(12),
    'cancel': (repo) => repo.cancelInvitation(12),
    'remove member': (repo) => repo.removeMember(5, 7),
    'change role': (repo) =>
        repo.changeMemberRole(5, 7, VaultMemberRole.editor),
  };

  final operations = <String, Future<Object?> Function(ApiVaultRepository)>{
    ...mutations,
    'accessible vaults': (repo) => repo.getMyVaults(),
    'members': (repo) => repo.getMembers(5),
    'owner invitations': (repo) => repo.getVaultInvitations(5),
    'incoming invitations': (repo) => repo.getMyInvitations(),
  };

  for (final operation in operations.entries) {
    for (final code in [400, 401, 403, 404, 409, 500]) {
      test('${operation.key} preserves HTTP $code', () async {
        final options = RequestOptions(path: '/test');

        failure = DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: code,
            data: {'message': 'Backend explanation'},
          ),
        );

        await expectLater(
          operation.value(repository),
          throwsA(same(failure)),
        );
      });
    }
  }

  for (final network in [NetworkStatus.offline, NetworkStatus.checking]) {
    test('all collaboration mutations are blocked while ${network.name}',
        () async {
      dio.interceptors.insert(
        0,
        OfflineMutationInterceptor(() => network),
      );

      for (final mutation in mutations.values) {
        await expectLater(
          mutation(repository),
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
