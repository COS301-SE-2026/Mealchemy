import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/features/profile/models/preference_option.dart';
import 'package:mealchemy/features/profile/models/user_preferences.dart';
import 'package:mealchemy/features/profile/models/user_profile.dart';
import 'package:mealchemy/features/profile/providers/profile_provider.dart';
import 'package:mealchemy/features/profile/repositories/profile_repository.dart';
import 'package:mealchemy/features/profile/screens/profile_screen.dart';

class _FakeRepo implements ProfileRepository {
  @override
  Future<UserProfile> getProfile() async => const UserProfile(
        displayName: 'Mutombo Kabau',
        email: 'mutombo@mealchemy.com',
        preferredUnit: PreferredUnit.metric,
        equipment: ['OVEN'],
      );
  @override
  Future<UserProfile> saveProfile(UserProfile profile) async => profile;

  @override
  Future<UserPreferences> getPreferences() async => const UserPreferences(
        dietaryRestrictions: ['GLUTEN_FREE'],
      );

  @override
  Future<UserPreferences> savePreferences(UserPreferences preferences) async =>
      preferences;
  @override
  Future<List<PreferenceOption>> getDietaryOptions() async => const [
        PreferenceOption(value: 'GLUTEN_FREE', label: 'Gluten-Free'),
        PreferenceOption(value: 'VEGAN', label: 'Vegan'),
      ];

  @override
  Future<List<PreferenceOption>> getAllergyOptions() async => const [];

  @override
  Future<List<PreferenceOption>> getNutritionalGoalOptions() async => const [];

  @override
  Future<List<PreferenceOption>> getFlavourProfileOptions() async => const [];

  @override
  Future<List<PreferenceOption>> getEquipmentOptions() async => const [
        PreferenceOption(value: 'OVEN', label: 'Oven'),
        PreferenceOption(value: 'BLENDER', label: 'Blender'),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

Widget _host(ProfileRepository repo) {
  final router = GoRouter(
    initialLocation: AppRoutes.profile,
    routes: [
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const Scaffold(body: ProfileScreen()),
      ),
    ],
  );

  return ProviderScope(
    overrides: [profileRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(routerConfig: router),
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

  testWidgets('renders the intro and identity once loaded', (tester) async {
    await tester.pumpWidget(_host(_FakeRepo()));
    await tester.pumpAndSettle();

    expect(find.text('Your Culinary\nProfile'), findsOneWidget);
    expect(find.text('Mutombo Kabau'), findsOneWidget);
  });

  testWidgets('the save button starts idle with nothing to save',
      (tester) async {
    await tester.pumpWidget(_host(_FakeRepo()));
    await tester.pumpAndSettle();

    expect(find.text('All Changes Saved'), findsOneWidget);
    final button = tester.widget<AppButton>(
      find.widgetWithText(AppButton, 'All Changes Saved'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('editing a field enables the save button', (tester) async {
    await tester.pumpWidget(_host(_FakeRepo()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Imperial'));
    await tester.pumpAndSettle();

    expect(find.text('Save Changes'), findsOneWidget);
    final button = tester.widget<AppButton>(
      find.widgetWithText(AppButton, 'Save Changes'),
    );
    expect(button.onPressed, isNotNull);
  });
}