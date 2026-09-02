import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/external_links/models/link.dart';
import 'package:mealchemy/features/external_links/providers/link_provider.dart';
import 'package:mealchemy/features/external_links/repositories/link_repository.dart';
import 'package:mealchemy/features/external_links/widgets/link_sheet.dart';

class _RecordingLinkRepository implements LinkRepository {
  String? createdName;
  String? createdUrl;
  int createCalls = 0;

  @override
  Future<List<Link>> getLinks() async => const [];

  @override
  Future<Link> createLink({required String name, required String url}) async {
    createCalls++;
    createdName = name;
    createdUrl = url;
    return Link(
      linkId: 1,
      name: name,
      url: url,
      createdAt: DateTime.parse('2026-08-31T23:00:00Z'),
    );
  }
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  Future<void> openSheet(WidgetTester tester, _RecordingLinkRepository repo) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [linkRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showLinkSheet(context: context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows validation errors on an empty submit', (tester) async {
    final repo = _RecordingLinkRepository();
    await openSheet(tester, repo);
    await tester.tap(find.text('Add Link'));
    await tester.pumpAndSettle();

    expect(find.text('Give the link a name.'), findsOneWidget);
    expect(find.text('Add a link.'), findsOneWidget);
    expect(repo.createCalls, 0);
  });

  testWidgets('rejects a url without http scheme', (tester) async {
    final repo = _RecordingLinkRepository();
    await openSheet(tester, repo);
    await tester.enterText(find.byType(TextField).at(0), 'My Recipe');
    await tester.enterText(find.byType(TextField).at(1), 'www.example.com');
    await tester.tap(find.text('Add Link'));
    await tester.pumpAndSettle();

    expect(
      find.text('Link must start with http:// or https://'),
      findsOneWidget,
    );
    expect(repo.createCalls, 0);
  });

  testWidgets('creates the link on a valid submit', (tester) async {
    final repo = _RecordingLinkRepository();
    await openSheet(tester, repo);
    await tester.enterText(find.byType(TextField).at(0), 'Creamy Pasta');
    await tester.enterText(
      find.byType(TextField).at(1),
      'https://example.com/pasta',
    );
    await tester.tap(find.text('Add Link'));
    await tester.pumpAndSettle();

    expect(repo.createCalls, 1);
    expect(repo.createdName, 'Creamy Pasta');
    expect(repo.createdUrl, 'https://example.com/pasta');
  });
}