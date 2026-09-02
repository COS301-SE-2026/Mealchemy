import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_dropdown.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host(List<AppDropdownItem> items) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppDropdown(
            trigger: const Text('Open'),
            items: items,
          ),
        ),
      ),
    );
  }

  testWidgets('renders the trigger', (tester) async {
    await tester.pumpWidget(host([
      AppDropdownItem(label: 'Profile', onTap: () {}),
    ]));

    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('does not show the menu until tapped', (tester) async {
    await tester.pumpWidget(host([
      AppDropdownItem(label: 'Profile', onTap: () {}),
    ]));

    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('opens the menu with all items on tap', (tester) async {
    await tester.pumpWidget(host([
      AppDropdownItem(label: 'Profile', onTap: () {}),
      AppDropdownItem(label: 'Log out', onTap: () {}, destructive: true),
    ]));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('tapping an item fires its onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(host([
      AppDropdownItem(label: 'Profile', onTap: () => tapped = true),
      AppDropdownItem(label: 'Log out', onTap: () {}),
    ]));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('closes the menu after an item is picked', (tester) async {
    await tester.pumpWidget(host([
      AppDropdownItem(label: 'Profile', onTap: () {}),
    ]));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('renders an item icon when provided', (tester) async {
    await tester.pumpWidget(host([
      AppDropdownItem(
        label: 'Profile',
        icon: Icons.person_outline,
        onTap: () {},
      ),
    ]));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });
}