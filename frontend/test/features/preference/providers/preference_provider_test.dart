import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/preference/providers/preference_provider.dart';
import 'package:mealchemy/features/preference/repositories/mock_preference_repository.dart';

void main() {
  //uses mock repo
  test('preferenceRepositoryProvider uses mock repository', () {
    //create Riverpod provider container for isolated testing
    final container = ProviderContainer();
    //delete container
    addTearDown(container.dispose);

    final repository = container.read(preferenceRepositoryProvider);

    //using mock repo
    expect(repository, isA<MockPreferenceRepository>());
  });

  test('userPreferencesProvider exposes mock preference data', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final preferences = await container.read(userPreferencesProvider.future);

    expect(preferences.selectedAllergies, contains('PEANUTS'));
    expect(preferences.flavourProfiles.first.selected, isTrue);
  });
}