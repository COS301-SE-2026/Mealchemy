import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/external_links/models/link.dart';
import 'package:mealchemy/features/external_links/widgets/link_row.dart';

Link _link({int id = 1}) => Link(
      linkId: id,
      name: 'Creamy Garlic Pasta',
      url: 'https://www.tiktok.com/video/123',
      createdAt: DateTime.parse('2026-08-31T23:00:00Z'),
    );

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(Widget child) => ProviderScope(
        child: MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets('renders the link name and url', (tester) async {
    await tester.pumpWidget(host(LinkRow(link: _link())));

    expect(find.text('Creamy Garlic Pasta'), findsOneWidget);
    expect(find.text('https://www.tiktok.com/video/123'),
        findsOneWidget);
  });

  testWidgets('shows edit and delete actions when mutations are enabled',
      (tester) async {
    await tester.pumpWidget(host(LinkRow(link: _link())));

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('hides actions when mutations are disabled', (tester) async {
    await tester.pumpWidget(
      host(LinkRow(link: _link(), mutationsEnabled: false)),
    );

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}