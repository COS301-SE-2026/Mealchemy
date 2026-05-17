import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/vault/screens/vault_screen.dart';

void main() {
  testWidgets('VaultScreen renders correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: VaultScreen()),
    );
    expect(find.text('Vault'), findsOneWidget);
  });
}