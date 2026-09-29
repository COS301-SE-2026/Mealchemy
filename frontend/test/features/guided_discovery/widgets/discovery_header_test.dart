import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/guided_discovery/widgets/discovery_header.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';

void main() {
  setUpAll(() {
    //disable google fonts fetching during tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host({
    int cartCount = 0,
    ValueChanged<String>? onFilterSelected,
    DiscoveryTab selectedTab = DiscoveryTab.discover,
  }) {
    return ProviderScope(
      overrides: [
        shoppingListCountProvider.overrideWithValue(cartCount),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: DiscoveryHeader(
            selectedFilter: 'All',
            filters: const [
              'All',
              'Quick Meals',
              'High Protein',
              'Vegetarian',
            ],
            onFilterSelected: onFilterSelected ?? (_) {},
            selectedTab: selectedTab,
          ),
        ),
      ),
    );
  }

  //tests that header shows UI elements
  testWidgets('DiscoveryHeader renders tabs and filters', (tester) async {
    await tester.pumpWidget(host());

    //main nav tabs
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Sizzles'), findsOneWidget);

    //filter chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Quick Meals'), findsOneWidget);
    expect(find.text('High Protein'), findsOneWidget);
    expect(find.text('Vegetarian'), findsOneWidget);

    //header buttons
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);
  });

  //tests that selecting a filter triggers filter selection
  testWidgets('DiscoveryHeader calls onFilterSelected when filter is tapped', (
    tester,
  ) async {
    String? selectedFilter;

    await tester.pumpWidget(
      host(onFilterSelected: (filter) => selectedFilter = filter),
    );

    await tester.tap(find.text('High Protein'));

    expect(selectedFilter, 'High Protein');
  });

  //filter chips only belong on the Discover tab
  testWidgets('DiscoveryHeader hides filters on the Sizzles tab', (
    tester,
  ) async {
    await tester.pumpWidget(host(selectedTab: DiscoveryTab.sizzles));

    expect(find.text('Sizzles'), findsOneWidget);
    expect(find.text('Quick Meals'), findsNothing);
    expect(find.text('High Protein'), findsNothing);
  });

  //badge shows the count from the provider
  testWidgets('DiscoveryHeader shows the shopping list count', (tester) async {
    await tester.pumpWidget(host(cartCount: 3));

    expect(find.text('3'), findsOneWidget);
  });
}