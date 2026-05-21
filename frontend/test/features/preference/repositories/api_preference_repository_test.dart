import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/preference/repositories/api_preference_repository.dart';

void main() {
  test('ApiPreferenceRepository throws until API integration is implemented', () {
    //create repo instance
    final repository = ApiPreferenceRepository();

    //ensure it fails
    expect(
      repository.getUserPreferences,
      throwsA(isA<UnimplementedError>()),
    );
  });
}