import '../models/user_preferences.dart';

//contratc used by mock and API data
abstract class PreferenceRepository {
  Future<UserPreferences> getUserPreferences();
}