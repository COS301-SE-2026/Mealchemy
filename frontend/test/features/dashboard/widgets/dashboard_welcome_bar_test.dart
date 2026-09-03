import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/dashboard/widgets/dashboard_welcome_bar.dart';
import 'package:mealchemy/features/profile/providers/profile_provider.dart';
import 'package:mealchemy/features/profile/repositories/profile_repository.dart';

class _FailingProfileRepository implements ProfileRepository {
  @override
  noSuchMethod(Invocation invocation) =>
      Future<Never>.error(Exception('no profile'));
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host() => ProviderScope(
        overrides: [
          profileRepositoryProvider
              .overrideWithValue(_FailingProfileRepository()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: DashboardWelcomeBar()),
        ),
      );

  testWidgets('falls back to Chef when the profile is unavailable',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('Chef?'), findsOneWidget);
  });

  testWidgets('always shows the welcome greeting', (tester) async {
    
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back, '), findsOneWidget);
    expect(find.text('What are we cooking today, '), findsOneWidget);
  });
}