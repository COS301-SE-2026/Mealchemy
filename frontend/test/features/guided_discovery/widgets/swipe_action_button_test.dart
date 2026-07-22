import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/features/guided_discovery/widgets/swipe_action_button.dart';

void main() {
  //tests swipe action
  testWidgets('SwipeActionButton renders icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwipeActionButton(
            icon: Icons.close,
            foregroundColor: AppColors.primary,
            backgroundColor: AppColors.surfaceWhite,
            borderColor: AppColors.accent,
            size: 70,
            onTap: () {},
          ),
        ),
      ),
    );

    //close icon present in widgets
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('SwipeActionButton calls onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwipeActionButton(
            icon: Icons.favorite,
            foregroundColor: AppColors.error,
            backgroundColor: AppColors.surfaceWhite,
            size: 70,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    //simulate user tapping button
    await tester.tap(find.byIcon(Icons.favorite));
    expect(tapped, isTrue);
  });
}