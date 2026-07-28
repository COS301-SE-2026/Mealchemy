import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/discovery/models/discovery_category.dart';
import 'package:mealchemy/features/discovery/models/explore_item.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';
import 'package:mealchemy/features/discovery/widgets/popular_categories_section.dart';

class _UnusedDiscoveryRepo implements DiscoveryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}
 
class _FakeDiscoveryNotifier extends DiscoveryNotifier {
  _FakeDiscoveryNotifier(DiscoveryState initial)
      : super(_UnusedDiscoveryRepo()) {
    state = initial;
  }
}
void main() {
    setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
 
  const cuisines = ['italian', 'japanese', 'indian'];

  Future<ProviderContainer> pumpSection(
    WidgetTester tester,
    DiscoveryState state,
  ) async {
    final container = ProviderContainer(
      overrides: [
        discoveryProvider.overrideWith((ref) => _FakeDiscoveryNotifier(state)),
      ],
    );
    addTearDown(container.dispose);
 
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
 
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: PopularCategoriesSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }
 
  group('PopularCategoriesSection', () {
    testWidgets('renders the section header', (tester) async {
      await pumpSection(tester, const DiscoveryState(cuisines: cuisines));
      expect(find.text('Popular Categories'), findsOneWidget);
    });
 
    testWidgets('renders an "All" entry plus each formatted cuisine',
        (tester) async {
      await pumpSection(tester, const DiscoveryState(cuisines: cuisines));
 
      expect(find.text('All'), findsOneWidget); // the null entry
      expect(find.text('Italian'), findsOneWidget);
      expect(find.text('Japanese'), findsOneWidget);
      expect(find.text('Indian'), findsOneWidget);
    });
 
    testWidgets('tapping a cuisine selects it on the provider', (tester) async {
      final container =
          await pumpSection(tester, const DiscoveryState(cuisines: cuisines));
 
      await tester.tap(find.text('Japanese'));
      await tester.pump();
 
      expect(container.read(discoveryProvider).selectedCuisine, 'japanese');
    });
 
    testWidgets('tapping "All" clears the selected cuisine', (tester) async {
      final container = await pumpSection(
        tester,
        const DiscoveryState(cuisines: cuisines, selectedCuisine: 'italian'),
      );
 
      await tester.tap(find.text('All'));
      await tester.pump();
 
      expect(container.read(discoveryProvider).selectedCuisine, isNull);
    });
  });
}