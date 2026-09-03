import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_dropdown.dart';
import 'package:mealchemy/core/shared_widgets/Organisms/app_header.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host({
    HeaderAction? left,
    HeaderAction? right,
    List<AppDropdownItem>? titleItems,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          appBar: AppHeader(
            left: left,
            right: right,
            titleItems: titleItems,
          ),
        ),
      ),
    );
  }

  testWidgets('always renders the Mealchemy title', (tester) async {
    await tester.pumpWidget(host());
    expect(find.text('Mealchemy'), findsOneWidget);
  });

  testWidgets('renders a plain title with no dropdown chevron when there are '
      'no title items', (tester) async {
    await tester.pumpWidget(host());
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
  });

  testWidgets('shows the dropdown chevron when title items are given',
      (tester) async {
    await tester.pumpWidget(
      host(titleItems: [
        AppDropdownItem(label: 'Profile', onTap: () {}),
      ]),
    );
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
  });

  testWidgets('renders the left and right slot icons', (tester) async {
    await tester.pumpWidget(
      host(
        left: HeaderAction(icon: Icons.person_outline, onTap: () {}),
        right: HeaderAction(icon: Icons.shopping_cart_outlined, onTap: () {}),
      ),
    );
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
  });

  testWidgets('shows a badge on a slot with a count', (tester) async {
    await tester.pumpWidget(
      host(
        right: HeaderAction(
          icon: Icons.shopping_cart_outlined,
          onTap: () {},
          badgeCount: 2,
        ),
      ),
    );
    expect(find.text('2'), findsOneWidget);
  });
  
  testWidgets('does not show a badge when the count is zero', (tester) async {
    await tester.pumpWidget(
      host(
        right: HeaderAction(
          icon: Icons.shopping_cart_outlined,
          onTap: () {},
        ),
      ),
    );
    expect(find.text('0'), findsNothing);
  });

  testWidgets('tapping the right slot fires its action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      host(
        right: HeaderAction(
          icon: Icons.shopping_cart_outlined,
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    expect(tapped, isTrue);
  });
}