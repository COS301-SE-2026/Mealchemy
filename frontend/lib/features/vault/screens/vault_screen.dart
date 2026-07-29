import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/shared_widgets/Organisms/app_navbar.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/widgets/vault_folder_list.dart';

import '../widgets/vault_hero.dart';

// Vault screen with the main widgets and layout.
class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultsAsync = ref.watch(vaultsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      bottomNavigationBar: AppNavbar(
        currentRoute: AppRoutes.vault,
        onRouteSelected: (route) => context.go(route),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addRecipe),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
        child: const Icon(Icons.add),
      ),
      body: vaultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _VaultError(message: '$error'),
        data: (vaults) {
          if (vaults.isEmpty) {
            return const _VaultError(message: 'No vault found.');
          }
          return const _VaultBody();
        },
      ),
    );
  }
}

class _VaultBody extends ConsumerWidget {
  const _VaultBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedVaultProvider);
    final isShared = ref.watch(isSharedModeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VaultHero(
              onSearch: () {},
              onAdd: () {},
              onShoppingList: () => context.push(AppRoutes.shoppingLists),
            ),
            if (selected == null && isShared)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                child: Text(
                  'No shared vaults yet.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              )
            else if (selected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: _VaultFoldersLoader(vault: selected),
              ),
          ],
        ),
      ),
    );
  }
}

class _VaultFoldersLoader extends ConsumerWidget {
  const _VaultFoldersLoader({required this.vault});
  final Vault vault;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(vaultFoldersProvider(vault.vaultId));

    return foldersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text(
        'Unable to load folders.',
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
      data: (folders) => VaultFolderList(
        vault: vault,
        folders: folders,
      ),
    );
  }
}
class _VaultError extends StatelessWidget {
  const _VaultError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unable to load vault.',
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}