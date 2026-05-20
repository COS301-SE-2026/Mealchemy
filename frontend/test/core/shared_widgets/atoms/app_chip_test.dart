import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_chip.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('AppChip renders label and remove icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppChip(
            label: 'PEANUTS',
            selected: true,
            onRemove: () {},
          ),
        ),
      ),
    );

    expect(find.text('PEANUTS'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('AppChip hides remove icon when onRemove is null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppChip(
            label: 'SOY',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('SOY'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });
}