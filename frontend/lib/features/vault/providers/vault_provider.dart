import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/features/vault/repositories/mock_vault_repository.dart';
import '../repositories/api_vault_repository.dart';
import '../repositories/vault_repository.dart';
import '../models/vault_folder.dart';
import '../../recipe/models/recipe.dart';
import '../../../core/constants/app_config.dart';

//Flag to switch between mock and real API implementations
final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockVaultRepository();
  }
  return ApiVaultRepository(Dio());
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