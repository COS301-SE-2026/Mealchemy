// Holds the user's preference profile (dietary restrictions, cuisines, etc.).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../models/user_preferences.dart';
import '../repositories/api_preference_repository.dart';
import '../repositories/mock_preference_repository.dart';
import '../repositories/preference_repository.dart';

//selects mock/API repo
final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockPreferenceRepository();
  }

  return ApiPreferenceRepository();
});

//exposes preference profile data
final userPreferencesProvider = FutureProvider<UserPreferences>((ref) {
  final repository = ref.watch(preferenceRepositoryProvider);
  return repository.getUserPreferences();
});