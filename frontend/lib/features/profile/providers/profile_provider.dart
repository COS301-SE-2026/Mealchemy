import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/providers/api_service_provider.dart';
import '../models/preference_option.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import '../repositories/api_profile_repository.dart';
import '../repositories/mock_profile_repository.dart';
import '../repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockProfileRepository();
  }
  return ApiProfileRepository(ref.read(dioProvider));
});

final dietaryProvider = FutureProvider<List<PreferenceOption>>((ref) {
  return ref.watch(profileRepositoryProvider).getDietaryOptions();
});

final allergyProvider = FutureProvider<List<PreferenceOption>>((ref) {
  return ref.watch(profileRepositoryProvider).getAllergyOptions();
});

final goalProvider = FutureProvider<List<PreferenceOption>>((ref) {
  return ref.watch(profileRepositoryProvider).getNutritionalGoalOptions();
});

final flavourProvider = FutureProvider<List<PreferenceOption>>((ref) {
  return ref.watch(profileRepositoryProvider).getFlavourProfileOptions();
});

final equipmentProvider = FutureProvider<List<PreferenceOption>>((ref) {
  return ref.watch(profileRepositoryProvider).getEquipmentOptions();
});

enum SaveStatus { idle, saving, success, error }

class ProfileEditState {
  const ProfileEditState({

    required this.original,
    required this.draft,
    this.saveStatus = SaveStatus.idle,
    this.errorMessage,

  });

  final UserProfile original;
  final UserProfile draft;
  final SaveStatus saveStatus;
  final String? errorMessage;

  bool get dirty {
    return draft.displayName != original.displayName ||
        draft.avatarUrl != original.avatarUrl ||
        draft.preferredUnit != original.preferredUnit ||
        !_sameSet(draft.equipment, original.equipment);
  }

  ProfileEditState copyWith({
    UserProfile? original,
    UserProfile? draft,
    SaveStatus? saveStatus,
    String? errorMessage,
  }) {
    return ProfileEditState(
      original: original ?? this.original,
      draft: draft ?? this.draft,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileEditState>> {
  ProfileNotifier(this._repository) : super(const AsyncLoading()) {
    _load();
  }

  final ProfileRepository _repository;

  Future<void> _load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final profile = await _repository.getProfile();
      return ProfileEditState(original: profile, draft: profile);
    });
  }

  Future<void> reload() => _load();
  void _edit(UserProfile Function(UserProfile draft) update) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: update(current.draft),
        saveStatus: SaveStatus.idle,
      ),
    );
  }

  void setDisplayName(String name) =>
      _edit((d) => d.copyWith(displayName: name));

  void setPreferredUnit(PreferredUnit unit) =>
      _edit((d) => d.copyWith(preferredUnit: unit));


  void toggleEquipment(String value) {
    _edit((d) {
      final next = [...d.equipment];
      next.contains(value) ? next.remove(value) : next.add(value);
      return d.copyWith(equipment: next);
    });
  }


  Future<void> save() async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(saveStatus: SaveStatus.saving));
    try {
      final saved = await _repository.saveProfile(current.draft);
      state = AsyncData(
        ProfileEditState(
          original: saved,
          draft: saved,
          saveStatus: SaveStatus.success,
        ),
      );
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          saveStatus: SaveStatus.error,
          errorMessage: 'Could not save your profile. Try again.',
        ),
      );
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileEditState>>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});

class PreferencesEditState {
  const PreferencesEditState({
    required this.original,
    required this.draft,
    this.saveStatus = SaveStatus.idle,
    this.errorMessage,
  });

  final UserPreferences original;
  final UserPreferences draft;
  final SaveStatus saveStatus;
  final String? errorMessage;

  bool get dirty {
    return !_sameSet(draft.dietaryRestrictions, original.dietaryRestrictions) ||
        !_sameSet(draft.allergies, original.allergies) ||
        !_sameSet(draft.dislikedIngredients, original.dislikedIngredients) ||
        !_sameSet(draft.flavourProfile, original.flavourProfile) ||
        !_sameSet(draft.nutritionalGoals, original.nutritionalGoals);
  }

  PreferencesEditState copyWith({
    UserPreferences? original,
    UserPreferences? draft,
    SaveStatus? saveStatus,
    String? errorMessage,
  }) {
    return PreferencesEditState(
      original: original ?? this.original,
      draft: draft ?? this.draft,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: errorMessage,
    );
  }
}

class PreferencesNotifier
    extends StateNotifier<AsyncValue<PreferencesEditState>> {
  PreferencesNotifier(this._repository) : super(const AsyncLoading()) {
    _load();
  }

  final ProfileRepository _repository;

  Future<void> _load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final prefs = await _repository.getPreferences();
      return PreferencesEditState(original: prefs, draft: prefs);
    });
  }


  Future<void> reload() => _load();

  void _edit(UserPreferences Function(UserPreferences draft) update) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: update(current.draft),
        saveStatus: SaveStatus.idle,
      ),
    );
  }

  static List<String> _toggle(List<String> list, String value) {
    final next = [...list];
    next.contains(value) ? next.remove(value) : next.add(value);
    return next;
  }

  void toggleDietary(String value) =>
      _edit((d) => d.copyWith(dietaryRestrictions: _toggle(d.dietaryRestrictions, value)));

  void toggleAllergy(String value) =>
      _edit((d) => d.copyWith(allergies: _toggle(d.allergies, value)));

  void toggleFlavour(String value) =>
      _edit((d) => d.copyWith(flavourProfile: _toggle(d.flavourProfile, value)));

  void toggleGoal(String value) =>
      _edit((d) => d.copyWith(nutritionalGoals: _toggle(d.nutritionalGoals, value)));


  void addDislikedIngredient(String name) {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.draft.dislikedIngredients.contains(name)) return;
    _edit((d) => d.copyWith(
          dislikedIngredients: [...d.dislikedIngredients, name],
        ));
  }

  void removeDislikedIngredient(String name) =>
      _edit((d) => d.copyWith(
            dislikedIngredients:
                d.dislikedIngredients.where((i) => i != name).toList(),
          ));

  Future<void> save() async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(saveStatus: SaveStatus.saving));
    try {
      final saved = await _repository.savePreferences(current.draft);
      state = AsyncData(
        PreferencesEditState(
          original: saved,
          draft: saved,
          saveStatus: SaveStatus.success,
        ),
      );
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          saveStatus: SaveStatus.error,
          errorMessage: 'Could not save your preferences. Try again.',
        ),
      );
    }
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, AsyncValue<PreferencesEditState>>(
        (ref) {
  return PreferencesNotifier(ref.watch(profileRepositoryProvider));
});


bool _sameSet(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  return a.toSet().containsAll(b);
}