import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/features/vault/repositories/mock_vault_repository.dart';
import '../repositories/api_vault_repository.dart';
import '../repositories/vault_repository.dart';
import '../models/vault_folder.dart';
import '../../recipe/models/recipe.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/providers/api_service_provider.dart';

//Flag to switch between mock and real API implementations
final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  const useMock = true;
  if (useMock) {
    return MockVaultRepository();
  }
  return ApiVaultRepository(ref.read(dioProvider));
});

//Vault folders provider 
final vaultFoldersProvider = FutureProvider<List<VaultFolder>>((ref) {
  
  return ref.watch(vaultRepositoryProvider).getFolders();
});

//Recipes in folder provider
final folderRecipesProvider =
    FutureProvider.family<List<Recipe>, int>((ref, folderId) {
  return ref.watch(vaultRepositoryProvider).getRecipesInFolder(folderId);
});