import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/dashboard/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen renders correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DashboardScreen()),
    );
    expect(find.text('Dashboard'), findsOneWidget);
  });
}