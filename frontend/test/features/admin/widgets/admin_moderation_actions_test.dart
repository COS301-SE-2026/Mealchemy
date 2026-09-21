import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/admin/models/admin_models.dart';
import 'package:mealchemy/features/admin/providers/admin_access_provider.dart';
import 'package:mealchemy/features/admin/providers/admin_moderation_provider.dart';
import 'package:mealchemy/features/admin/repositories/admin_repository.dart';
import 'package:mealchemy/features/admin/widgets/admin_moderation_actions.dart';

const _session = (
  userId: 7,
  token: 'test-token',
  restoring: false,
  hasValidCredential: true,
  network: NetworkStatus.online,
);

FlaggedRecipe _flag(FlagStatus status) => FlaggedRecipe(
      flaggedId: 12,
      recipeId: 87,
      recipeTitle: 'Ramen',
      flaggedByUserId: 4,
      reasonValue: 'SPAM_MISLEADING',
      reasonLabel: 'Spam / misleading',
      status: status,
      flaggedAt: DateTime.utc(2026, 9, 19),
    );

class _Repository implements AdminRepository {
  int removals = 0;
  int dismissals = 0;

  @override
  Future<FlaggedRecipe> removeFromCommunity(int flaggedId) async {
    removals++;
    return _flag(FlagStatus.removed);
  }

  @override
  Future<FlaggedRecipe> dismissFlag(int flaggedId) async {
    dismissals++;
    return _flag(FlagStatus.reviewed);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Widget _host(
  _Repository repository, {
  FlagStatus status = FlagStatus.pending,
}) =>
    ProviderScope(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repository),
        adminAccessContextProvider.overrideWithValue(_session),
        adminAccessStateProvider.overrideWith(
          (ref) => AdminAccess.allowed,
        ),
        adminModerationRefreshProvider.overrideWithValue((_, __) {}),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AdminModerationActions(flag: _flag(status)),
          ),
        ),
      ),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('cancel removal does not send a request', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(_host(repository));

    await tester.tap(find.text('Remove from community'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('The author keeps it in their private vault'),
      findsOneWidget,
    );
    expect(repository.removals, 0);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.removals, 0);
  });

  testWidgets('confirmation sends the removal request', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(_host(repository));

    await tester.tap(find.text('Remove from community'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(repository.removals, 1);
    expect(repository.dismissals, 0);
  });

  testWidgets('dismiss confirmation sends the dismiss request', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(_host(repository));

    await tester.tap(find.text('Dismiss report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(repository.dismissals, 1);
    expect(repository.removals, 0);
  });

  testWidgets('resolved reports have no moderation buttons', (tester) async {
    await tester.pumpWidget(
      _host(_Repository(), status: FlagStatus.reviewed),
    );

    expect(find.text('Dismiss report'), findsNothing);
    expect(find.text('Remove from community'), findsNothing);
  });
}
