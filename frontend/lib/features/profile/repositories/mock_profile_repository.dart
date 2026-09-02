import '../models/preference_option.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import 'profile_repository.dart';


class MockProfileRepository implements ProfileRepository {
  MockProfileRepository() {
    _profile = UserProfile(
      displayName: 'Mutombo Kabau',
      email: 'mutombo@mealchemy.com',
      avatarUrl: null,
      preferredUnit: PreferredUnit.metric,
      equipment: const ['OVEN', 'STOVETOP', 'MICROWAVE'],
      updatedAt: DateTime.now(),
    );
    _preferences = const UserPreferences(
      dietaryRestrictions: ['GLUTEN_FREE'],
      allergies: ['PEANUTS', 'SHELLFISH'],
      dislikedIngredients: ['Cilantro', 'Blue cheese, crumbled'],
      flavourProfile: ['italian', 'japanese'],
      nutritionalGoals: ['HIGH_PROTEIN'],
    );
  }

  late UserProfile _profile;
  late UserPreferences _preferences;

  static const _delay = Duration(milliseconds: 500);

  @override
  Future<UserProfile> getProfile() async {
    await Future.delayed(_delay);
    return _profile;
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    await Future.delayed(_delay);
    _profile = profile.copyWith(email: _profile.email, updatedAt: DateTime.now());
    return _profile;
  }

  @override
  Future<UserPreferences> getPreferences() async {
    await Future.delayed(_delay);
    return _preferences;
  }

  @override
  Future<UserPreferences> savePreferences(UserPreferences preferences) async {
    await Future.delayed(_delay);
    _preferences = preferences;
    return _preferences;
  }

  @override
  Future<List<PreferenceOption>> getDietaryOptions() async => const [
        PreferenceOption(id: 1, value: 'VEGETARIAN', label: 'Vegetarian'),
        PreferenceOption(id: 2, value: 'VEGAN', label: 'Vegan'),
        PreferenceOption(id: 3, value: 'GLUTEN_FREE', label: 'Gluten-Free'),
        PreferenceOption(id: 4, value: 'DAIRY_FREE', label: 'Dairy-Free'),
        PreferenceOption(id: 5, value: 'PESCATARIAN', label: 'Pescatarian'),
        PreferenceOption(id: 6, value: 'HALAL', label: 'Halal'),
        PreferenceOption(id: 7, value: 'KOSHER', label: 'Kosher'),
      ];

  @override
  Future<List<PreferenceOption>> getAllergyOptions() async => const [
        PreferenceOption(id: 1, value: 'PEANUTS', label: 'Peanuts'),
        PreferenceOption(id: 2, value: 'TREE_NUTS', label: 'Tree Nuts'),
        PreferenceOption(id: 3, value: 'SHELLFISH', label: 'Shellfish'),
        PreferenceOption(id: 4, value: 'SOY', label: 'Soy'),
        PreferenceOption(id: 5, value: 'EGGS', label: 'Eggs'),
        PreferenceOption(id: 6, value: 'DAIRY', label: 'Dairy'),
        PreferenceOption(id: 7, value: 'WHEAT', label: 'Wheat'),
        PreferenceOption(id: 8, value: 'FISH', label: 'Fish'),
      ];

  @override
  Future<List<PreferenceOption>> getNutritionalGoalOptions() async => const [
        PreferenceOption(id: 1, value: 'HIGH_PROTEIN', label: 'High Protein'),
        PreferenceOption(id: 2, value: 'LOW_CARB', label: 'Low Carb'),
      ];

  @override
  Future<List<PreferenceOption>> getFlavourProfileOptions() async => const [
        PreferenceOption(value: 'italian', label: 'Italian'),
        PreferenceOption(value: 'japanese', label: 'Japanese'),
        PreferenceOption(value: 'mexican', label: 'Mexican'),
        PreferenceOption(value: 'indian', label: 'Indian'),
        PreferenceOption(value: 'thai', label: 'Thai'),
        PreferenceOption(value: 'french', label: 'French'),
        PreferenceOption(value: 'mediterranean', label: 'Mediterranean'),
        PreferenceOption(value: 'chinese', label: 'Chinese'),
      ];

  @override
  Future<List<PreferenceOption>> getEquipmentOptions() async => const [
        PreferenceOption(id: 1, value: 'OVEN', label: 'Oven'),
        PreferenceOption(id: 2, value: 'STOVETOP', label: 'Stovetop'),
        PreferenceOption(id: 3, value: 'MICROWAVE', label: 'Microwave'),
        PreferenceOption(id: 4, value: 'AIR_FRYER', label: 'Air Fryer'),
        PreferenceOption(id: 5, value: 'BLENDER', label: 'Blender'),
        PreferenceOption(id: 6, value: 'SLOW_COOKER', label: 'Slow Cooker'),
        PreferenceOption(id: 7, value: 'GRILL', label: 'Grill'),
        PreferenceOption(id: 8, value: 'FOOD_PROCESSOR', label: 'Food Processor'),
      ];
}