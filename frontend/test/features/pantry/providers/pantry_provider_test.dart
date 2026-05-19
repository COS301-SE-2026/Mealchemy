import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';
import 'package:mealchemy/features/pantry/repositories/mock_pantry_repository.dart';

void main() {
  test('pantryRepositoryProvider uses mock repository', () {
    //create Riverpod provider container for isolated testing
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repository = container.read(pantryRepositoryProvider);

    expect(repository, isA<MockPantryRepository>());
  });
}