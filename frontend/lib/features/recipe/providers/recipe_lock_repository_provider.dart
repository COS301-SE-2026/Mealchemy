import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_service_provider.dart';
import '../repositories/api_recipe_lock_repository.dart';
import '../repositories/recipe_lock_repository.dart';

final recipeLockRepositoryProvider = Provider<RecipeLockRepository>((ref) {
  return ApiRecipeLockRepository(ref.watch(dioProvider));
});
