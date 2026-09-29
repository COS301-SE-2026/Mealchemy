import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/cook_session.dart';
import '../services/cook_session_store.dart';

final cookSessionStoreProvider = Provider<CookSessionStore>((ref) {
  return FileCookSessionStore();
});

class CookSessionController extends StateNotifier<int> {
  CookSessionController(this._store) : super(0);

  final CookSessionStore _store;

  Future<void> save(int userId, CookSession session) async {
    await _store.save(userId, session);
    if (mounted) state++;
  }

  Future<void> remove(int userId, int recipeId) async {
    await _store.remove(userId, recipeId);
    if (mounted) state++;
  }
}

final cookSessionControllerProvider =
    StateNotifierProvider<CookSessionController, int>((ref) {
  return CookSessionController(ref.watch(cookSessionStoreProvider));
});

final cookSessionForRecipeProvider =
    FutureProvider.family<CookSession?, int>((ref, recipeId) async {
  ref.watch(cookSessionControllerProvider);
  final userId = ref.watch(activeIdentityProvider);
  if (userId == null) return null;
  return ref.watch(cookSessionStoreProvider).read(userId, recipeId);
});

final latestCookSessionProvider = FutureProvider<CookSession?>((ref) async {
  ref.watch(cookSessionControllerProvider);
  final userId = ref.watch(activeIdentityProvider);
  if (userId == null) return null;
  return ref.watch(cookSessionStoreProvider).latest(userId);
});
