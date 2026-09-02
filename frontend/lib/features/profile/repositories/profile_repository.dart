import '../models/preference_option.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';

// One repo covers the whole profile screen the user own profile and preferences (read + save), and the catalogs 
abstract class ProfileRepository {
  Future<UserProfile> getProfile();

  Future<UserProfile> saveProfile(UserProfile profile);

  Future<UserPreferences> getPreferences();

  Future<UserPreferences> savePreferences(UserPreferences preferences);

  Future<List<PreferenceOption>> getDietaryOptions();

  Future<List<PreferenceOption>> getAllergyOptions();

  Future<List<PreferenceOption>> getNutritionalGoalOptions();

  Future<List<PreferenceOption>> getFlavourProfileOptions();

  Future<List<PreferenceOption>> getEquipmentOptions();
}