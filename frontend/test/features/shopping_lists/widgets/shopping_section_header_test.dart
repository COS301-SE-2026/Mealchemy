import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/shopping_lists/widgets/shopping_section_header.dart';

void main() {
  setUpAll(() {
    //disable google fonts during tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });
  
  //section header (title)
  testWidgets('ShoppingSectionHeader renders title and trailing label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShoppingSectionHeader(
            title: 'Lists',
            trailing: '6 lists',
          ),
        ),
      ),
    );

    //correct format
    expect(find.text('LISTS'), findsOneWidget);
    expect(find.text('6 LISTS'), findsOneWidget);
  });

  testWidgets('ShoppingSectionHeader renders without trailing label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShoppingSectionHeader(
            title: 'General list',
          ),
        ),
      ),
    );

    //title
    expect(find.text('GENERAL LIST'), findsOneWidget);
  });
}