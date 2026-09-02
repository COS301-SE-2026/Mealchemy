import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/external_links/models/link.dart';
import 'package:mealchemy/features/external_links/providers/link_provider.dart';
import 'package:mealchemy/features/external_links/repositories/link_repository.dart';
import 'package:mealchemy/features/external_links/widgets/my_links_folder_row.dart';

// Fake repo whose getLinks returns a fixed result (or throws), so the real
// notifier drives real loading/data/error transitions from controlled input.
class _FakeLinkRepository implements LinkRepository {
  _FakeLinkRepository({this.links = const [], this.fail = false});

  final List<Link> links;
  final bool fail;

  @override
  Future<List<Link>> getLinks() async {
    if (fail) throw Exception('boom');
    return links;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Link _link(int id, String name) => Link(
      linkId: id,
      name: name,
      url: 'https://example.com/$id',
      createdAt: DateTime.parse('2026-08-31T23:00:00Z'),
    );

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(LinkRepository repo) => ProviderScope(
        overrides: [linkRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(
          home: Scaffold(body: MyLinksFolderRow()),
        ),
      );

  testWidgets('shows the folder header and link count', (tester) async {
    await tester.pumpWidget(host(
      _FakeLinkRepository(links: [_link(1, 'A'), _link(2, 'B')]),
    ));
    await tester.pumpAndSettle();

    expect(find.text('My Links'), findsOneWidget);
    expect(find.text('2 links'), findsOneWidget);
  });

  testWidgets('tapping the header expands to reveal links', (tester) async {
    await tester.pumpWidget(host(
      _FakeLinkRepository(links: [_link(1, 'Lasagna Link')]),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Links'));
    await tester.pumpAndSettle();

    expect(find.text('Lasagna Link'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no links', (tester) async {
    await tester.pumpWidget(host(_FakeLinkRepository(links: const [])));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Links'));
    await tester.pumpAndSettle();
    expect(find.text('No links saved yet.'), findsOneWidget);
  });

  testWidgets('shows error state when loading fails', (tester) async {
    await tester.pumpWidget(host(_FakeLinkRepository(fail: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Links'));
    await tester.pumpAndSettle();

    expect(find.text('Unable to load links.'), findsOneWidget);
  });
}