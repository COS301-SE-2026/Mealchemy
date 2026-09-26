import 'package:dio/dio.dart';

import '../models/recipe_edit_lock.dart';
import 'recipe_lock_repository.dart';

//share one store between mock users to simulate competing editors
class MockRecipeLockStore {
  final Map<int, RecipeEditLock> _locks = {};
}

class MockRecipeLockRepository implements RecipeLockRepository {
  MockRecipeLockRepository({
    required this.store,
    required this.userId,
    required this.email,
    required this.canAccess,
    required this.canEdit,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final MockRecipeLockStore store;
  final int userId;
  final String email;

  //permission callbacks allow tests to simulate removal or demotion
  final bool Function(int recipeId) canAccess;
  final bool Function(int recipeId) canEdit;

  final DateTime Function() _now;

  static const ttl = Duration(seconds: 90);

  @override
  Future<RecipeEditLock?> getLock(int recipeId) async {
    _checkAccess(recipeId, 'GET');

    final lock = store._locks[recipeId];

    if (lock == null || lock.isExpiredAt(_now().toUtc())) {
      return null;
    }

    return lock;
  }

  @override
  Future<RecipeEditLock> acquireLock(int recipeId) async {
    _checkAccess(recipeId, 'POST');

    if (!canEdit(recipeId)) {
      throw _error(recipeId, 'POST', 404, 'Recipe not found.');
    }

    final now = _now().toUtc();
    final existing = store._locks[recipeId];
    final active = existing != null && !existing.isExpiredAt(now);

    if (active && !existing.isHeldBy(userId)) {
      throw _error(
        recipeId,
        'POST',
        409,
        'This recipe is currently being edited by another user.',
      );
    }

    final lock = RecipeEditLock(
      recipeId: recipeId,
      lockedByUserId: userId,
      lockedByEmail: email,
      acquiredAt: active ? existing.acquiredAt : now,
      expiresAt: now.add(ttl),
    );

    store._locks[recipeId] = lock;
    return lock;
  }

  @override
  Future<void> releaseLock(int recipeId) async {
    _checkAccess(recipeId, 'DELETE');

    final existing = store._locks[recipeId];

    if (existing == null) {
      throw _error(
        recipeId,
        'DELETE',
        404,
        'No active lock on this recipe.',
      );
    }

    if (!existing.isHeldBy(userId)) {
      throw _error(
        recipeId,
        'DELETE',
        403,
        'Only the lock holder can release this lock.',
      );
    }

    store._locks.remove(recipeId);
  }

  void _checkAccess(int recipeId, String method) {
    if (recipeId <= 0) {
      throw ArgumentError.value(recipeId, 'recipeId', 'Must be positive.');
    }

    if (!canAccess(recipeId)) {
      throw _error(recipeId, method, 404, 'Recipe not found.');
    }
  }

  DioException _error(
    int recipeId,
    String method,
    int status,
    String message,
  ) {
    final request = RequestOptions(
      path: '/recipes/$recipeId/lock',
      method: method,
    );

    return DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: status,
        data: {'message': message},
      ),
    );
  }
}
