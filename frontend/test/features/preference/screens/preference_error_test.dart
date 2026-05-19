import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/preference/models/user_preferences.dart';
import 'package:mealchemy/features/preference/providers/preference_provider.dart';
import 'package:mealchemy/features/preference/repositories/preference_repository.dart';
import 'package:mealchemy/features/preference/screens/preference_screen.dart';

//mock repo to similate API calls
class _FailingPreferenceRepository implements PreferenceRepository {
  @override
  //simulate repo failure
  Future<UserPreferences> getUserPreferences() {
    throw Exception('Preference failure');
  }
}

void main() {
  //disable font fetching
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  //dislays correct error state
  testWidgets('PreferenceScreen renders error state', (tester) async {
    //context required
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferenceRepositoryProvider.overrideWithValue(
            _FailingPreferenceRepository(),
          ),
        ],
        child: const MaterialApp(
          home: PreferenceScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unable to load preferences.'), findsOneWidget);
  });
}