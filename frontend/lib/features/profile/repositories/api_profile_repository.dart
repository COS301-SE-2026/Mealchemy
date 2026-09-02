import 'package:dio/dio.dart';

import '../models/preference_option.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import 'profile_repository.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._dio);

  final Dio _dio;
  @override
  Future<UserProfile> getProfile() async {
    final res = await _dio.get('/user/profile');

    return UserProfile.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    final res = await _dio.put('/user/profile', data: profile.toUpdateJson());
    return UserProfile.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<UserPreferences> getPreferences() async {
    final res = await _dio.get('/user/preferences');
    return UserPreferences.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<UserPreferences> savePreferences(UserPreferences preferences) async {
    final res = await _dio.put(
      '/user/preferences',
      data: preferences.toJson(),
    );

    return UserPreferences.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<PreferenceOption>> getDietaryOptions() =>
      _options('/dietaryrestrictions/all');

  @override
  Future<List<PreferenceOption>> getAllergyOptions() =>
      _options('/allergies/all');

  @override
  Future<List<PreferenceOption>> getNutritionalGoalOptions() =>
      _options('/nutritionalgoals/all');

  @override
  Future<List<PreferenceOption>> getFlavourProfileOptions() =>
      _options('/flavourprofileoptions/all');

  @override
  Future<List<PreferenceOption>> getEquipmentOptions() =>
      _options('/api/equipment');

  Future<List<PreferenceOption>> _options(String path) async {
    final res = await _dio.get(path);
    
    return (res.data as List<dynamic>)
        .map((e) => PreferenceOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
