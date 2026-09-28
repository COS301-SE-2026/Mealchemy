import 'package:flutter_test/flutter_test.dart';

import 'package:mealchemy/features/auth/providers/login_lockout_provider.dart';

void main() {
  testWidgets('lockout is specific to the submitted email', (tester) async {
    final now = DateTime.utc(2026, 9, 28);
    final notifier = LoginLockoutNotifier(now: () => now);

    try {
      notifier.record(' first@example.com ', 300);

      expect(notifier.remainingSeconds('first@example.com'), 300);
      expect(notifier.remainingSeconds('second@example.com'), 0);
    } finally {
      notifier.dispose();
    }
  });

  testWidgets('expiry uses elapsed time rather than timer tick count',
      (tester) async {
    var now = DateTime.utc(2026, 9, 28);
    final notifier = LoginLockoutNotifier(now: () => now);

    try {
      notifier.record('test@example.com', 300);

      now = now.add(const Duration(seconds: 240));
      notifier.refresh();

      expect(notifier.remainingSeconds('test@example.com'), 60);

      now = now.add(const Duration(seconds: 60));
      notifier.refresh();

      expect(notifier.remainingSeconds('test@example.com'), 0);
      expect(notifier.state, isEmpty);
    } finally {
      notifier.dispose();
    }
  });

  testWidgets('a new server response replaces the previous expiry',
      (tester) async {
    var now = DateTime.utc(2026, 9, 28);
    final notifier = LoginLockoutNotifier(now: () => now);

    try {
      notifier.record('test@example.com', 300);
      now = now.add(const Duration(seconds: 30));

      notifier.record('test@example.com', 120);

      expect(notifier.remainingSeconds('test@example.com'), 120);
    } finally {
      notifier.dispose();
    }
  });

  testWidgets('clearing one account preserves another account lockout',
      (tester) async {
    final notifier = LoginLockoutNotifier(
      now: () => DateTime.utc(2026, 9, 28),
    );

    try {
      notifier.record('first@example.com', 300);
      notifier.record('second@example.com', 120);

      notifier.clear('first@example.com');

      expect(notifier.remainingSeconds('first@example.com'), 0);
      expect(notifier.remainingSeconds('second@example.com'), 120);
    } finally {
      notifier.dispose();
    }
  });
}
