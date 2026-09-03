import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/ingredients/models/pending_external_ingredient.dart';

void main() {
  test('PendingExternalIngredient maps 422 response', () {
    final ingredient = PendingExternalIngredient.fromJson({
      'source_id': '2710077',
      'name': 'Kimchi',
    });

    expect(ingredient.sourceId, '2710077');
    expect(ingredient.name, 'Kimchi');
  });

  test('PendingExternalIngredient rejects missing source id', () {
    expect(
      () => PendingExternalIngredient.fromJson({
        'name': 'Kimchi',
      }),
      throwsFormatException,
    );
  });
}
