import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_chip.dart';
import 'package:mealchemy/features/profile/models/preference_option.dart';
import 'package:mealchemy/features/profile/models/user_preferences.dart';
import 'package:mealchemy/features/profile/models/user_profile.dart';
import 'package:mealchemy/features/profile/providers/profile_provider.dart';
import 'package:mealchemy/features/profile/repositories/profile_repository.dart';
import 'package:mealchemy/features/profile/widgets/information_section.dart';

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
  Future<UserPreferences> getPreferences() async => const UserPreferences();

  @override
  Future<UserPreferences> savePreferences(UserPreferences preferences) async =>
      preferences;

  @override
  Future<List<PreferenceOption>> getEquipmentOptions() async => const [
        PreferenceOption(value: 'OVEN', label: 'Oven'),
        PreferenceOption(value: 'BLENDER', label: 'Blender'),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

Widget _host() {
  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(_FakeRepo()),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: InformationSection()),
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

  testWidgets('renders the identity card from the profile', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    expect(find.text('Mutombo Kabau'), findsOneWidget);
    expect(find.text('mutombo@mealchemy.com'), findsOneWidget);
  });

  testWidgets('shows the preferred unit toggle with both options',
      (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('Metric'), findsOneWidget);
    expect(find.text('Imperial'), findsOneWidget);
  });

  testWidgets('renders seeded equipment as a chip', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppChip, 'Oven'), findsOneWidget);
  });

  testWidgets('tapping a new equipment option adds it', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add equipment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blender'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppChip, 'Blender'), findsOneWidget);
  });
}