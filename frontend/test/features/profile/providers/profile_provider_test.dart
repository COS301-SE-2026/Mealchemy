import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/profile/models/preference_option.dart';
import 'package:mealchemy/features/profile/models/user_preferences.dart';
import 'package:mealchemy/features/profile/models/user_profile.dart';
import 'package:mealchemy/features/profile/providers/profile_provider.dart';
import 'package:mealchemy/features/profile/repositories/profile_repository.dart';

const _profile = UserProfile(
  displayName: 'Mutombo Kabau',
  email: 'mutombo@mealchemy.com',
  preferredUnit: PreferredUnit.metric,
  equipment: ['OVEN', 'BLENDER'],
);

const _prefs = UserPreferences(
  dietaryRestrictions: ['GLUTEN_FREE'],
  allergies: ['PEANUTS'],
  dislikedIngredients: ['Hummus, commercial'],
  flavourProfile: ['ITALIAN'],
  nutritionalGoals: ['HIGH_PROTEIN'],
);

class _RecordingRepo implements ProfileRepository {
  final List<UserProfile> savedProfiles = [];
  final List<UserPreferences> savedPreferences = [];

  @override
  Future<UserProfile> getProfile() async => _profile;

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    savedProfiles.add(profile);
    return profile;
  }

  @override
  Future<UserPreferences> getPreferences() async => _prefs;

  @override
  Future<UserPreferences> savePreferences(UserPreferences preferences) async {
    savedPreferences.add(preferences);
    return preferences;
  }

  @override
  Future<List<PreferenceOption>> getDietaryOptions() async => const [
        PreferenceOption(value: 'GLUTEN_FREE', label: 'Gluten-Free'),
        PreferenceOption(value: 'VEGAN', label: 'Vegan'),
      ];
  @override
  Future<List<PreferenceOption>> getAllergyOptions() async => const [
        PreferenceOption(value: 'PEANUTS', label: 'Peanuts'),
      ];

  @override
  Future<List<PreferenceOption>> getNutritionalGoalOptions() async => const [
        PreferenceOption(value: 'HIGH_PROTEIN', label: 'High Protein'),
      ];

  @override
  Future<List<PreferenceOption>> getFlavourProfileOptions() async => const [
        PreferenceOption(value: 'ITALIAN', label: 'Italian'),
      ];
  @override
  Future<List<PreferenceOption>> getEquipmentOptions() async => const [
        PreferenceOption(value: 'OVEN', label: 'Oven'),
        PreferenceOption(value: 'BLENDER', label: 'Blender'),
        PreferenceOption(value: 'MICROWAVE', label: 'Microwave'),
      ];
}

class _ThrowingSaveRepo extends _RecordingRepo {
  @override
  Future<UserProfile> saveProfile(UserProfile profile) async =>
      throw Exception('backend down');

  @override
  Future<UserPreferences> savePreferences(UserPreferences preferences) async =>
      throw Exception('backend down');
}

ProviderContainer makeContainer({ProfileRepository? repo}) {
  return ProviderContainer(
    overrides: [
      profileRepositoryProvider.overrideWithValue(repo ?? _RecordingRepo()),
    ],
  );
}


Future<T> _loaded<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider,
) async {
  final completer = Completer<T>();
  final sub = container.listen(provider, (_, next) {
    if (completer.isCompleted) return;
    if (next is AsyncData<T>) {
      completer.complete(next.value);
    } else if (next is AsyncError<T>) {
      completer.completeError(next.error);
    }
  }, fireImmediately: true);
  try {
    return await completer.future;
  } finally {
    sub.close();
  }
}

void main() {
  group('profileRepositoryProvider', () {
    test('resolves a ProfileRepository', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
          container.read(profileRepositoryProvider), isA<ProfileRepository>());
    });
  });

  group('option catalog providers', () {
    test(' Equipment Options Provider shows the repo options', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      final options = await container.read(equipmentProvider.future);
      expect(options, hasLength(3));
      expect(options.map((o) => o.value), containsAll(['OVEN', 'MICROWAVE']));
    });

    test('Dietary Options Provider shows the repo options ', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      final options = await container.read(dietaryProvider.future);
      expect(options.map((o) => o.value), contains('GLUTEN_FREE'));
    });
  });

  group('ProfileNotifier', () {
    test('loads the profile into orignal and draft', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final state = await _loaded(container, profileProvider);
      expect(state.draft.displayName, 'Mutombo Kabau');
      expect(state.dirty, isFalse);
    });

    test('editing the unit marks the draft dirty', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await _loaded(container, profileProvider);

      container.read(profileProvider.notifier).setPreferredUnit(
            PreferredUnit.imperial,
          );
      final state = container.read(profileProvider).value!;
      expect(state.draft.preferredUnit, PreferredUnit.imperial);
      expect(state.dirty, isTrue);
    });

    test('toggling equipment adds then removes a value', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await _loaded(container, profileProvider);
      final notifier = container.read(profileProvider.notifier);

      notifier.toggleEquipment('MICROWAVE');
      expect(container.read(profileProvider).value!.draft.equipment,
          containsAll(['OVEN', 'BLENDER', 'MICROWAVE']));

      notifier.toggleEquipment('MICROWAVE');
      expect(container.read(profileProvider).value!.draft.equipment,
          isNot(contains('MICROWAVE')));
    });

    test('toggling equipment back to the saved set is not dirty ', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await _loaded(container, profileProvider);
      final notifier = container.read(profileProvider.notifier);
      notifier.toggleEquipment('MICROWAVE');
      notifier.toggleEquipment('MICROWAVE');

      expect(container.read(profileProvider).value!.dirty, isFalse);
    });

    test('save sends the draft and  clears dirty on success', () async {
      final repo = _RecordingRepo();
      final container = makeContainer(repo: repo);
      addTearDown(container.dispose);
      await _loaded(container, profileProvider);
      final notifier = container.read(profileProvider.notifier);

      notifier.setPreferredUnit(PreferredUnit.imperial);
      await notifier.save();

      expect(repo.savedProfiles.single.preferredUnit, PreferredUnit.imperial);
      final state = container.read(profileProvider).value!;
      expect(state.saveStatus, SaveStatus.success);
      expect(state.dirty, isFalse);
    });

    test('save sets an error status when the repo throws ', () async {
      final container = makeContainer(repo: _ThrowingSaveRepo());
      addTearDown(container.dispose);
      await _loaded(container, profileProvider);
      final notifier = container.read(profileProvider.notifier);

      notifier.setPreferredUnit(PreferredUnit.imperial);
      await notifier.save();

      final state = container.read(profileProvider).value!;
      expect(state.saveStatus, SaveStatus.error);
      expect(state.errorMessage, isNotNull);
      expect(state.dirty, isTrue); 
    });
  });

  group('PreferencesNotifier', () {
    test('loads preferences into original and draft', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final state = await _loaded(container, preferencesProvider);

      expect(state.draft.dietaryRestrictions, ['GLUTEN_FREE']);
      expect(state.dirty, isFalse);
    });

    test('toggling a dietary value adds then removes it', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await _loaded(container, preferencesProvider);
      final notifier = container.read(preferencesProvider.notifier);

      notifier.toggleDietary('VEGAN');
      expect(
          container.read(preferencesProvider).value!.draft.dietaryRestrictions,
          containsAll(['GLUTEN_FREE', 'VEGAN']));

      notifier.toggleDietary('VEGAN');
      expect(
          container.read(preferencesProvider).value!.draft.dietaryRestrictions,
          isNot(contains('VEGAN')));
    });

    test('adds a disliked ingredient by its exact name, ignoring duplicates',
        () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await _loaded(container, preferencesProvider);
      final notifier = container.read(preferencesProvider.notifier);

      notifier.addDislikedIngredient('Mustard, prepared, yellow');
      expect(
        container.read(preferencesProvider).value!.draft.dislikedIngredients,
        ['Hummus, commercial', 'Mustard, prepared, yellow'],
      );

      notifier.addDislikedIngredient('Hummus, commercial');
      expect(
        container
            .read(preferencesProvider)
            .value!
            .draft
            .dislikedIngredients
            .where((e) => e == 'Hummus, commercial'),
        hasLength(1),
      );
    });

    test('removes a disliked ingredient', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await _loaded(container, preferencesProvider);
      final notifier = container.read(preferencesProvider.notifier);

      notifier.removeDislikedIngredient('Hummus, commercial');

      expect(
        container.read(preferencesProvider).value!.draft.dislikedIngredients,
        isEmpty,
      );
    });

    test('save sends the draft and clears dirty on success', () async {
      final repo = _RecordingRepo();
      final container = makeContainer(repo: repo);
      addTearDown(container.dispose);
      await _loaded(container, preferencesProvider);
      final notifier = container.read(preferencesProvider.notifier);

      notifier.toggleGoal('HIGH_PROTEIN'); // removes it
      await notifier.save();

      expect(repo.savedPreferences.single.nutritionalGoals, isEmpty);
      final state = container.read(preferencesProvider).value!;
      expect(state.saveStatus, SaveStatus.success);
      expect(state.dirty, isFalse);
    });

    test('save sets an error status when the repo throws', () async {
      final container = makeContainer(repo: _ThrowingSaveRepo());
      addTearDown(container.dispose);
      await _loaded(container, preferencesProvider);
      final notifier = container.read(preferencesProvider.notifier);

      notifier.toggleAllergy('PEANUTS');
      await notifier.save();

      final state = container.read(preferencesProvider).value!;
      expect(state.saveStatus, SaveStatus.error);
      expect(state.dirty, isTrue);
    });
  });
}
