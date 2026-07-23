import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/guided_discovery/widgets/discovery_header.dart';

void main() {
  setUpAll(() {
    //disable google fonts fetching during tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  //tests that header shows UI elements
  testWidgets('DiscoveryHeader renders tabs and filters', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoveryHeader(
            selectedFilter: 'All',
            filters: const [
              'All',
              'Quick Meals',
              'High Protein',
              'Vegetarian',
            ],
            onFilterSelected: (_) {},
          ),
        ),
      ),
    );

    //main nav tabs
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Sizzles'), findsOneWidget);

    //filter tabs
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Quick Meals'), findsOneWidget);
    expect(find.text('High Protein'), findsOneWidget);
    expect(find.text('Vegetarian'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);
  });

  //tests that selecting a filter triggeres filter selection
  testWidgets('DiscoveryHeader calls onFilterSelected when filter is tapped', (
    tester,
  ) async {
    String? selectedFilter;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoveryHeader(
            selectedFilter: 'All',
            filters: const [
              'All',
              'Quick Meals',
              'High Protein',
              'Vegetarian',
            ],
            onFilterSelected: (filter) => selectedFilter = filter,
          ),
        ),
      ),
    );

    await tester.tap(find.text('High Protein'));

    expect(selectedFilter, 'High Protein');
  });
}