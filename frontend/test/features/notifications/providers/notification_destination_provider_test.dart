import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/notifications/models/vault_notification.dart';
import 'package:mealchemy/features/notifications/providers/notification_destination_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_invitation.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';

VaultNotification _notification(
  String type, {
  int? vaultId = 3,
  int? recipeId = 118,
  int? invitationId = 9,
}) {
  return VaultNotification(
    notificationId: 42,
    rawType: type,
    message: 'Server notification text',
    isRead: false,
    createdAt: DateTime.utc(2026, 9, 27),
    refVaultId: vaultId,
    refRecipeId: recipeId,
    refInvitationId: invitationId,
  );
}

Vault _vault() => Vault(
      vaultId: 3,
      ownerId: 1,
      vaultType: VaultTypes.shared,
      name: 'Family',
      createdAt: DateTime.utc(2026),
    );

DioException _error(int status) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: options,
      statusCode: status,
    ),
  );
}

class _Vaults extends Fake implements VaultRepository {
  int vaultCalls = 0;
  Future<Vault> Function()? loadVault;
  List<VaultInvitation> invitations = [];

  @override
  Future<Vault> getVaultById(int vaultId) async {
    vaultCalls++;
    return loadVault == null ? _vault() : await loadVault!();
  }

  @override
  Future<List<VaultInvitation>> getMyInvitations() async => invitations;
}

class _Recipes extends Fake implements RecipeRepository {
  int calls = 0;
  int? failure;

  @override
  Future<Recipe> getRecipeById(int id) async {
    calls++;
    if (failure != null) throw _error(failure!);
    return Recipe(recipeId: id, title: 'Pasta');
  }
}

void main() {
  late _Vaults vaults;
  late _Recipes recipes;
  late NotificationDestinationResolver resolver;
  late bool current;

  setUp(() {
    vaults = _Vaults();
    recipes = _Recipes();
    current = true;

    resolver = NotificationDestinationResolver(
      vaults: vaults,
      recipes: recipes,
      isCurrentSession: () => current,
    );
  });

  for (final type in [
    'MEMBER_REMOVED',
    'INVITATION_CANCELLED',
    'INVITATION_DECLINED',
    'FUTURE_EVENT',
  ]) {
    test('$type does not navigate or make access requests', () async {
      final notification = _notification(type);

      expect(notificationCanOpen(notification), isFalse);
      expect(await resolver.resolve(notification), isNull);
      expect(vaults.vaultCalls, 0);
      expect(recipes.calls, 0);
    });
  }

  test('missing recipe reference prevents navigation', () {
    expect(
      notificationCanOpen(
        _notification('RECIPE_EDITED', recipeId: null),
      ),
      isFalse,
    );
  });

  test('recipe notifications check vault and recipe access', () async {
    final target = await resolver.resolve(
      _notification('RECIPE_EDITED'),
    );

    expect(target!.location, '/recipe/118?vaultId=3');
    expect(target.selectedVaultId, isNull);
    expect(vaults.vaultCalls, 1);
    expect(recipes.calls, 1);
  });

  test('removed recipe opens its vault without fetching the recipe', () async {
    final target = await resolver.resolve(
      _notification('RECIPE_REMOVED'),
    );

    expect(target!.location, AppRoutes.vault);
    expect(target.selectedVaultId, 3);
    expect(recipes.calls, 0);
  });

  for (final status in [403, 404]) {
    test('vault $status produces a friendly access message', () async {
      vaults.loadVault = () async => throw _error(status);

      await expectLater(
        resolver.resolve(_notification('RECIPE_EDITED')),
        throwsA(
          isA<NotificationDestinationException>().having(
            (error) => error.message,
            'message',
            'You no longer have access to this vault.',
          ),
        ),
      );

      expect(recipes.calls, 0);
    });

    test('recipe $status produces a friendly unavailable message', () async {
      recipes.failure = status;

      await expectLater(
        resolver.resolve(_notification('RECIPE_EDITED')),
        throwsA(
          isA<NotificationDestinationException>().having(
            (error) => error.message,
            'message',
            'This recipe was removed or is no longer available.',
          ),
        ),
      );
    });
  }

  test('pending invitation opens invitations without checking vault access',
      () async {
    vaults.invitations = [
      VaultInvitation(
        invitationId: 9,
        vaultId: 3,
        vaultName: 'Family',
        invitedEmail: 'sofia@example.com',
        invitedByEmail: 'gabriela@example.com',
        status: VaultInvitationStatus.pending,
        createdAt: DateTime.utc(2026, 9, 27),
        expiresAt: DateTime.utc(2026, 10, 27),
      ),
    ];

    final target = await resolver.resolve(_notification('VAULT_INVITE'));

    expect(target!.location, AppRoutes.incomingVaultInvitations);
    expect(vaults.vaultCalls, 0);
  });

  test('missing invitation shows unavailable instead of opening a vault',
      () async {
    await expectLater(
      resolver.resolve(_notification('VAULT_INVITE')),
      throwsA(
        isA<NotificationDestinationException>().having(
          (error) => error.message,
          'message',
          'This invitation is no longer available.',
        ),
      ),
    );
  });

  test('session change stops the next access request', () async {
    final pending = Completer<Vault>();
    vaults.loadVault = () => pending.future;

    final request = resolver.resolve(_notification('RECIPE_EDITED'));
    current = false;
    pending.complete(_vault());

    await expectLater(
      request,
      throwsA(isA<NotificationDestinationException>()),
    );

    expect(recipes.calls, 0);
  });
}
