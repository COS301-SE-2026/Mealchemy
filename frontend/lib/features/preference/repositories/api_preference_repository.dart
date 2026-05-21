import '../models/user_preferences.dart';
import 'preference_repository.dart';

//backend data (for future use)
class ApiPreferenceRepository implements PreferenceRepository {
  @override
  Future<UserPreferences> getUserPreferences() {
    throw UnimplementedError(
      'Preference API integration has not been implemented yet.',
    );
  }
}