import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/preference/models/preference_weights.dart';
import 'package:mealchemy/features/preference/providers/weights_provider.dart';
import 'package:mealchemy/features/preference/repositories/weights_repository.dart';
import 'package:mealchemy/features/preference/screens/weights_screen.dart';
import 'package:mealchemy/features/preference/widgets/weight_slider.dart';

class _FakeWeightsRepository implements WeightsRepository {
  PreferenceWeights? saved;

  @override
  Future<PreferenceWeights> getWeights() async => PreferenceWeights.defaults;

  @override
  Future<PreferenceWeights> saveWeights(PreferenceWeights weights) async {
    saved = weights;
    return weights;
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late _FakeWeightsRepository repo;

  Widget host() {
    repo = _FakeWeightsRepository();
    return ProviderScope(
      overrides: [weightsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const WeightsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  group('WeightsScreen', () {
    testWidgets('renders a slider for every sigal once loaded', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.byType(WeightSlider), findsNWidgets(5));
      expect(find.text('Pantry Match'), findsOneWidget);
    });

    testWidgets('Save persists the current weights through the repository',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(repo.saved, isNotNull);
      expect(repo.saved!.total, closeTo(1.0, 0.0001));
    });

    testWidgets('help button opens the  signals sheet', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();
      expect(find.text('How recommendations work'), findsOneWidget);
    });
  });
}