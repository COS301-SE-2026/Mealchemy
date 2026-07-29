import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/providers/api_service_provider.dart';
import 'package:mealchemy/core/constants/app_config.dart';
import '../repositories/vault_repository.dart';
import '../repositories/mock_vault_repository.dart';
import '../repositories/api_vault_repository.dart';

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  if (AppConfig.mockVault) {
    return MockVaultRepository();
  }

  return ApiVaultRepository(ref.read(dioProvider));
});