import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mealchemy/features/vault/repositories/api_vault_repository.dart';

void main() {
  // Testing api vault reposetory instantiates correctly
  test('creates ApiVaultRepository with Dio', () {

    final repo =  ApiVaultRepository(Dio());

    expect(repo, isNotNull );
  });
}