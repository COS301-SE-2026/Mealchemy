import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/preference/repositories/mock_preference_repository.dart';

void main() {
  //make sure it actually returns mock data
  test('MockPreferenceRepository returns preference profile data', () async {
    //mock repo instance (no API)
    final repository = MockPreferenceRepository();

    final preferences = await repository.getUserPreferences();

    //expected mock data
    expect(preferences.dietaryDirectives, isNotEmpty);
    expect(preferences.selectedAllergies, contains('PEANUTS'));
    expect(preferences.dislikedIngredients, contains('CILANTRO'));
    expect(preferences.flavourProfiles.first.selected, isTrue);
  });
}