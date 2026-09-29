import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/guided_discovery/models/signal.dart';

void main() {
  test('fromJson maps signal key to type', () {
    final signal = Signal.fromJson({
      'signal': 'pantry_match',
      'percentage': 90,
      'message': 'Matched 8 of 9 ingredients you already have on hand.',
    });

    expect(signal.type, 'pantry_match');
    expect(signal.percentage, 90);
    expect(signal.message, 'Matched 8 of 9 ingredients you already have on hand.');
  });

  test('fromJson rounds a decimal percentage', () {
    final signal = Signal.fromJson({
      'signal': 'nutrition',
      'percentage': 72.6,
      'message': 'Contains 18g of protein toward your high-protein goal.',
    });

    expect(signal.percentage, 73);
  });
}