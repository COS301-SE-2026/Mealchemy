import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_chip.dart';
import 'package:mealchemy/features/ingredients/providers/ingredient_catalogue_provider.dart';
import 'package:mealchemy/features/profile/models/preference_option.dart';
import 'package:mealchemy/features/profile/models/user_preferences.dart';
import 'package:mealchemy/features/profile/models/user_profile.dart';
import 'package:mealchemy/features/profile/providers/profile_provider.dart';
import 'package:mealchemy/features/profile/repositories/profile_repository.dart';
import 'package:mealchemy/features/profile/widgets/preferences_section.dart';

class _FakeRepo implements ProfileRepository {
  final UserPreferences preferences;
  _FakeRepo({this.preferences = const UserPreferences()});

  @override
  Future<UserProfile> getProfile() async => const UserProfile(
        displayName: 'Chef',
        preferredUnit: PreferredUnit.metric,
        equipment: [],
      );

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async => profile;

  @override
  Future<UserPreferences> getPreferences() async => preferences;

  @override
  Future<UserPreferences> savePreferences(UserPreferences p) async => p;

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
  Future<List<PreferenceOption>> getEquipmentOptions() async => const [];
}

Widget _host(_FakeRepo repo) {
  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(repo),
      catalogueSearchProvider.overrideWith((ref, query) async => const []),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: PreferencesSection()),
      ),
    ),
  );
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2400);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('renders the five section headers', (tester) async {
    await tester.pumpWidget(_host(_FakeRepo()));
    await tester.pumpAndSettle();

    expect(find.text('Dietary Directives'), findsOneWidget);
    expect(find.text('Critical Allergies'), findsOneWidget);
    expect(find.text('Aversions'), findsOneWidget);
    expect(find.text('Flavour Profiles'), findsOneWidget);
    expect(find.text('Nutritional Goals'), findsOneWidget);
  });

  testWidgets('renders a selected preference as a chip', (tester) async {
    await tester.pumpWidget(_host(
      _FakeRepo(
        preferences:
            const UserPreferences(dietaryRestrictions: ['GLUTEN_FREE']),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppChip, 'Gluten-Free'), findsOneWidget);
  });

  testWidgets('adding an option from the dietary picker shows a chip',
      (tester) async {
    await tester.pumpWidget(_host(_FakeRepo()));
    await tester.pumpAndSettle();

    // Add restriction opens the dietary picker pick Vegan.
    await tester.tap(find.text('Add restriction').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vegan').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppChip, 'Vegan'), findsOneWidget);
  });

  testWidgets('removing a selected preference chip deselects it',
      (tester) async {
    await tester.pumpWidget(_host(
      _FakeRepo(
        preferences: const UserPreferences(allergies: ['PEANUTS']),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppChip, 'Peanuts'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppChip, 'Peanuts'), findsNothing);
  });
}