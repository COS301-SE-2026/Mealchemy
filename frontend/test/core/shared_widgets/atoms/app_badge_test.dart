import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_badge.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  Widget host(int count) {
    return MaterialApp(
      home: Scaffold(body: AppBadge(count: count)),
    );
  }

  testWidgets('renders nothing when count is zero', (tester) async {
    await tester.pumpWidget(host(0));
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('shows the count when positive', (tester) async {
    await tester.pumpWidget(host(4));
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('caps the display at 99+', (tester) async {
    await tester.pumpWidget(host(150));
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('shows 99 exactly without the plus', (tester) async {
    await tester.pumpWidget(host(99));
    expect(find.text('99'), findsOneWidget);
  });
}