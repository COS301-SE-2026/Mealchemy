import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mealchemy/features/profile/models/user_profile.dart';
import 'package:mealchemy/features/profile/providers/profile_provider.dart';
import 'package:mealchemy/features/profile/repositories/profile_repository.dart';
import 'package:mealchemy/features/recipe/models/unit_of_measurement.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';

class _Profiles implements ProfileRepository {
  UserProfile profile = const UserProfile(
    displayName: 'Test User',
    preferredUnit: PreferredUnit.metric,
    equipment: [],
  );

  bool failSave = false;

  @override
  Future<UserProfile> getProfile() async => profile;

  @override
  Future<UserProfile> saveProfile(UserProfile value) async {
    if (failSave) throw StateError('Save failed');
    profile = value;
    return profile;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _Recipes implements RecipeRepository {
  _Recipes(this.profiles);

  final _Profiles profiles;
  int calls = 0;

  @override
  Future<List<UnitOfMeasurement>> getUnits() async {
    calls++;

    if (profiles.profile.preferredUnit == PreferredUnit.imperial) {
      return const [
        UnitOfMeasurement(
          unitId: 2,
          name: 'oz',
          system: 'IMPERIAL',
        ),
      ];
    }

    return const [
      UnitOfMeasurement(
        unitId: 1,
        name: 'g',
        system: 'METRIC',
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late _Profiles profiles;
  late _Recipes recipes;
  late ProfileNotifier profileNotifier;
  late ProviderContainer container;

  setUp(() async {
    profiles = _Profiles();
    recipes = _Recipes(profiles);
    profileNotifier = ProfileNotifier(profiles);

    container = ProviderContainer(
      overrides: [
        profileProvider.overrideWith((ref) => profileNotifier),
        recipeRepositoryProvider.overrideWithValue(recipes),
      ],
    );

    container.read(profileProvider);
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() {
    container.dispose();
  });

  test('saving imperial preference fetches imperial units', () async {
    final initial = await container.read(unitsProvider.future);
    expect(initial.single.name, 'g');

    final initialCalls = recipes.calls;

    profileNotifier.setPreferredUnit(PreferredUnit.imperial);

    // An unsaved draft must not change the units used elsewhere.
    expect(container.read(unitSystemProvider), PreferredUnit.metric);
    expect(
      (await container.read(unitsProvider.future)).single.name,
      'g',
    );
    expect(recipes.calls, initialCalls);

    await profileNotifier.save();

    expect(container.read(unitSystemProvider), PreferredUnit.imperial);
    expect(
      (await container.read(unitsProvider.future)).single.name,
      'oz',
    );
    expect(recipes.calls, initialCalls + 1);
    expect(container.read(unitOptionsProvider).single.name, 'oz');
  });

  test('failed preference save preserves existing units', () async {
    await container.read(unitsProvider.future);
    final initialCalls = recipes.calls;

    profiles.failSave = true;
    profileNotifier.setPreferredUnit(PreferredUnit.imperial);
    await profileNotifier.save();

    expect(container.read(unitSystemProvider), PreferredUnit.metric);
    expect(
      (await container.read(unitsProvider.future)).single.name,
      'g',
    );
    expect(recipes.calls, initialCalls);
  });
}
