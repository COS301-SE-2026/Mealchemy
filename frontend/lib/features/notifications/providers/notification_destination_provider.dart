import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_service_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../recipe/providers/recipe_provider.dart';
import '../../recipe/repositories/recipe_repository.dart';
import '../../vault/models/vault.dart';
import '../../vault/providers/shared_vault_access_provider.dart';
import '../../vault/repositories/api_vault_repository.dart';
import '../../vault/repositories/vault_repository.dart';
import '../models/vault_notification.dart';

bool notificationCanOpen(VaultNotification notification) {
  return switch (notification.type) {
    VaultNotificationType.vaultInvite =>
      notification.refVaultId != null && notification.refInvitationId != null,
    VaultNotificationType.recipeAdded ||
    VaultNotificationType.recipeEdited =>
      notification.refVaultId != null && notification.refRecipeId != null,
    VaultNotificationType.invitationAccepted ||
    VaultNotificationType.roleChanged ||
    VaultNotificationType.recipeRemoved ||
    VaultNotificationType.folderCreated ||
    VaultNotificationType.folderDeleted =>
      notification.refVaultId != null,
    _ => false,
  };
}

class NotificationDestination {
  const NotificationDestination({
    required this.location,
    this.selectedVaultId,
  });

  final String location;

  //set only when nav should select vault in the Vault screen
  final int? selectedVaultId;
}

class NotificationDestinationException implements Exception {
  const NotificationDestinationException(this.message);

  final String message;
}

class NotificationDestinationResolver {
  NotificationDestinationResolver({
    required VaultRepository vaults,
    required RecipeRepository recipes,
    required bool Function() isCurrentSession,
  })  : _vaults = vaults,
        _recipes = recipes,
        _isCurrentSession = isCurrentSession;

  final VaultRepository _vaults;
  final RecipeRepository _recipes;
  final bool Function() _isCurrentSession;

  void _checkSession() {
    if (!_isCurrentSession()) {
      throw const NotificationDestinationException(
        'Your session changed. Open the notification again after signing in.',
      );
    }
  }

  Future<T> _read<T>(
    Future<T> Function() request, {
    required String unavailable,
  }) async {
    _checkSession();

    try {
      final result = await request();
      _checkSession();
      return result;
    } on DioException catch (error) {
      final status = error.response?.statusCode;

      if (status == 401) {
        throw const NotificationDestinationException(
          'Sign in again to open this notification.',
        );
      }

      if (status == 403 || status == 404) {
        throw NotificationDestinationException(unavailable);
      }

      throw const NotificationDestinationException(
        'Could not check access. Check your connection and try again.',
      );
    }
  }

  Future<NotificationDestination?> resolve(
    VaultNotification notification,
  ) async {
    _checkSession();

    if (!notificationCanOpen(notification)) return null;

    final vaultId = notification.refVaultId!;

    //invitee does not need access to vault before accepting
    if (notification.type == VaultNotificationType.vaultInvite) {
      final invitations = await _read(
        _vaults.getMyInvitations,
        unavailable: 'This invitation is no longer available.',
      );

      final pending = invitations.any(
        (invitation) =>
            invitation.invitationId == notification.refInvitationId &&
            invitation.vaultId == vaultId &&
            invitation.isPending,
      );

      if (!pending) {
        throw const NotificationDestinationException(
          'This invitation is no longer available.',
        );
      }

      return const NotificationDestination(
        location: AppRoutes.incomingVaultInvitations,
      );
    }

    final vault = await _read(
      () => _vaults.getVaultById(vaultId),
      unavailable: 'You no longer have access to this vault.',
    );

    if (vault.vaultId != vaultId || vault.vaultType != VaultTypes.shared) {
      throw const NotificationDestinationException(
        'This shared vault is no longer available.',
      );
    }

    if (notification.type == VaultNotificationType.recipeAdded ||
        notification.type == VaultNotificationType.recipeEdited) {
      final recipeId = notification.refRecipeId!;

      final recipe = await _read(
        () => _recipes.getRecipeById(recipeId),
        unavailable: 'This recipe was removed or is no longer available.',
      );

      if (recipe.recipeId != recipeId) {
        throw const NotificationDestinationException(
          'This recipe is no longer available.',
        );
      }

      return NotificationDestination(
        location: Uri(
          path: '/recipe/$recipeId',
          queryParameters: {'vaultId': '$vaultId'},
        ).toString(),
      );
    }

    //RECIPE_REMOVED deliberately opens vault, not old recipe.
    return NotificationDestination(
      location: AppRoutes.vault,
      selectedVaultId: vaultId,
    );
  }
}

final notificationDestinationResolverProvider =
    Provider<NotificationDestinationResolver>((ref) {
  final session = ref.watch(vaultSessionProvider);
  var disposed = false;
  ref.onDispose(() => disposed = true);

  return NotificationDestinationResolver(
    //access checks must use backend, not offline cache fallback
    vaults: ApiVaultRepository(ref.watch(dioProvider)),
    recipes: ref.watch(remoteRecipeRepositoryProvider),
    isCurrentSession: () =>
        !disposed &&
        ref.read(vaultSessionProvider) == session &&
        !session.restoring &&
        session.hasValidCredential &&
        session.userId != null &&
        session.token != null,
  );
});
