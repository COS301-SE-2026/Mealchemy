import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/providers/api_service_provider.dart';
import 'package:mealchemy/core/constants/app_config.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/offline/providers/offline_cache_provider.dart';
import 'package:mealchemy/features/offline/repositories/cached_vault_repository.dart';
import '../repositories/vault_repository.dart';
import '../repositories/mock_vault_repository.dart';
import '../repositories/api_vault_repository.dart';

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  if (AppConfig.mockVault) {
    return MockVaultRepository();
  }
  final remote = ApiVaultRepository(ref.read(dioProvider));
  final viewerUserId = ref.watch(activeIdentityProvider);
  if (viewerUserId == null) return remote;

  return CachedVaultRepository(
    remote: remote,
    cache: ref.watch(offlineCacheStoreProvider),
    viewerUserId: viewerUserId,
  );
});
