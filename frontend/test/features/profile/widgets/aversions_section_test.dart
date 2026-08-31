import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_chip.dart';
import 'package:mealchemy/features/ingredients/models/ingredient_catalogue_item.dart';
import 'package:mealchemy/features/ingredients/providers/ingredient_catalogue_provider.dart';
import 'package:mealchemy/features/profile/models/preference_option.dart';
import 'package:mealchemy/features/profile/models/user_preferences.dart';
import 'package:mealchemy/features/profile/models/user_profile.dart';
import 'package:mealchemy/features/profile/providers/profile_provider.dart';
import 'package:mealchemy/features/profile/repositories/profile_repository.dart';
import 'package:mealchemy/features/profile/widgets/aversions_section.dart';

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
  Future<List<PreferenceOption>> getDietaryOptions() async => const [];

  @override
  Future<List<PreferenceOption>> getAllergyOptions() async => const [];

  @override
  Future<List<PreferenceOption>> getNutritionalGoalOptions() async => const [];

  @override
  Future<List<PreferenceOption>> getFlavourProfileOptions() async => const [];

  @override
  Future<List<PreferenceOption>> getEquipmentOptions() async => const [];
}


Widget _host(_FakeRepo repo, {List<IngredientCatalogueItem> hits = const []}) {
  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(repo),
      catalogueSearchProvider.overrideWith((ref, query) async => hits),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Consumer(
            builder: (context, ref, _) {
              final prefs = ref.watch(preferencesProvider).valueOrNull;
              if (prefs == null) return const SizedBox.shrink();
              return AversionsSection(disliked: prefs.draft.dislikedIngredients);
            },
          ),
        ),
      ),
    ),
  );
}

const _hummus = IngredientCatalogueItem(
  ingId: 1,
  name: 'Hummus, commercial',
  category: 'Legumes',
);

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

  testWidgets('renders existing disliked ingredients as chips', (tester) async {
    await tester.pumpWidget(_host(
      _FakeRepo(
        preferences:
            const UserPreferences(dislikedIngredients: ['Cilantro']),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppChip, 'Cilantro'), findsOneWidget);
  });


  testWidgets('typing two or more characters shows catalogue results',
      (tester) async {
    await tester.pumpWidget(_host(_FakeRepo(), hits: const [_hummus]));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hum');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Hummus, commercial'), findsOneWidget);
  });

  testWidgets('picking a result adds it as a chip by its exact name',
      (tester) async {
    await tester.pumpWidget(_host(_FakeRepo(), hits: const [_hummus]));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'hum');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hummus, commercial'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppChip, 'Hummus, commercial'), findsOneWidget);
  });

  testWidgets('removing a chip drops the ingredient', (tester) async {
    await tester.pumpWidget(_host(
      _FakeRepo(
        preferences:
            const UserPreferences(dislikedIngredients: ['Cilantro']),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppChip, 'Cilantro'), findsNothing);
  });

  testWidgets('shows the no matches message when the catalogue is empty',
      (tester) async {
    await tester.pumpWidget(_host(_FakeRepo()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('No matches in the catalogue.'), findsOneWidget);
  });
}