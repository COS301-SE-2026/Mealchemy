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

    //load preference data from provider
    final preferences = await container.read(userPreferencesProvider.future);

    //check mock allergy data exists
    expect(preferences.selectedAllergies, contains('PEANUTS'));
    expect(preferences.flavourProfiles.first.selected, isTrue);
  });

  test('toggleDietaryDirective updates selected state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(userPreferencesProvider.future);

    //get notifier instance
    final notifier = container.read(userPreferencesProvider.notifier);
    notifier.toggleDietaryDirective('PLANT-BASED / VEGAN');

    final preferences = container.read(userPreferencesProvider).value!;

    //ensure dietary directive selected
    expect(preferences.dietaryDirectives.first.selected, isTrue);
  });

  //checks allergy gets moved into selected allergies list
  test('selectAllergy moves allergy into selected list', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    //wait for provider initialization
    await container.read(userPreferencesProvider.future);

    final notifier = container.read(userPreferencesProvider.notifier);
    //select allergy
    notifier.selectAllergy('SOY');

    final preferences = container.read(userPreferencesProvider).value!;

    expect(preferences.selectedAllergies, contains('SOY'));
    expect(preferences.availableAllergies, isNot(contains('SOY')));
  });

  //checks allergy is moved back into available list
  test('removeAllergy moves allergy back into available list', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(userPreferencesProvider.future);

    final notifier = container.read(userPreferencesProvider.notifier);
    //remove allergy from list
    notifier.removeAllergy('PEANUTS');

    final preferences = container.read(userPreferencesProvider).value!;

    expect(preferences.selectedAllergies, isNot(contains('PEANUTS')));
    expect(preferences.availableAllergies, contains('PEANUTS'));
  });

  //formatting
  test('addDislikedIngredient adds uppercase trimmed ingredient', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(userPreferencesProvider.future);

    final notifier = container.read(userPreferencesProvider.notifier);
    //add with spaces and lowercase
    notifier.addDislikedIngredient(' mushrooms ');

    final preferences = container.read(userPreferencesProvider).value!;

    //trimmed and changed to uppercase
    expect(preferences.dislikedIngredients, contains('MUSHROOMS'));
  });

  //checks disliked ingredient removal
  test('removeDislikedIngredient removes ingredient', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(userPreferencesProvider.future);

    final notifier = container.read(userPreferencesProvider.notifier);
    notifier.removeDislikedIngredient('CILANTRO');

    //read updated preferences
    final preferences = container.read(userPreferencesProvider).value!;

    expect(preferences.dislikedIngredients, isNot(contains('CILANTRO')));
  });

  //flavour profile selection
  test('toggleFlavourProfile updates selected state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(userPreferencesProvider.future);

    final notifier = container.read(userPreferencesProvider.notifier);
    notifier.toggleFlavourProfile('Asian Fusion');

    final preferences = container.read(userPreferencesProvider).value!;
    final asianProfile = preferences.flavourProfiles.firstWhere(
      (profile) => profile.label == 'Asian Fusion',
    );

    expect(asianProfile.selected, isTrue);
  });

  //resets back to original data
  test('resetPreferences restores original mock data', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(userPreferencesProvider.future);

    final notifier = container.read(userPreferencesProvider.notifier);
    //modify before reset
    notifier.selectAllergy('SOY');
    await notifier.resetPreferences();

    final preferences = container.read(userPreferencesProvider).value!;

    expect(preferences.selectedAllergies, isNot(contains('SOY')));
    expect(preferences.selectedAllergies, contains('PEANUTS'));
  });
}