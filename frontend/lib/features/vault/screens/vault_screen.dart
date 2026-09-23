import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_refresh.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/widgets/vault_folder_list.dart';
import '../../../core/connectivity/network_status_provider.dart';
import '../../../core/shared_widgets/Molecules/app_search_bar.dart';
import '../../external_links/widgets/link_row.dart';
import '../widgets/folder_recipe_row.dart';
import '../providers/shared_vault_access_provider.dart';
import '../widgets/shared_vault_members_entry.dart';

import '../widgets/vault_hero.dart';
import '../../offline/data/offline_cache_store.dart';
import '../../offline/widgets/cache_freshness_label.dart';

// Vault screen with the main widgets and layout.
class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultsAsync = ref.watch(vaultsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Recipe',
        onPressed: () => context.push(AppRoutes.addRecipe),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
        child: const Icon(Icons.add),
      ),
      body: AppRefresh(
        onRefresh: () async {
          ref.invalidate(sharedVaultAccessProvider);
          ref.invalidate(vaultMembersProvider);
          ref.invalidate(vaultFoldersProvider);
          ref.invalidate(folderRecipesProvider);
          ref.invalidate(vaultSearchResultsProvider);

          ref.invalidate(vaultsProvider);

          try {
            await ref.read(vaultsProvider.future);
          } catch (_) {
            // The screen displays the current loading/error state.
          }
        },
        child: vaultsAsync.when(
          loading: () => const _ScrollableCentre(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => _ScrollableCentre(
            child: _VaultError(message: '$error'),
          ),
          data: (vaults) {
            if (vaults.isEmpty) {
              return const _ScrollableCentre(
                child: _VaultError(message: 'No vault found.'),
              );
            }
            return const _VaultBody();
          },
        ),
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
    final searchQuery = ref.watch(vaultSearchQueryProvider);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VaultHero(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: CacheFreshnessLabel(
                collection: CacheCollection.vaults,
                scopeId: CacheScope.all,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: AppSearchBar(
                hint: 'Search this vault...',
                onChanged: (value) {
                  ref.read(vaultSearchQueryProvider.notifier).state = value;
                },
              ),
            ),
            if (selected != null && selected.vaultType == VaultTypes.shared)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: SharedVaultMembersEntry(
                  key: ValueKey(selected.vaultId),
                  vaultId: selected.vaultId,
                ),
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
                child: _VaultFoldersLoader(
                  vault: selected,
                  searchQuery: searchQuery,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VaultFoldersLoader extends ConsumerWidget {
  const _VaultFoldersLoader({
    required this.vault,
    required this.searchQuery,
  });

  final Vault vault;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(vaultFoldersProvider(vault.vaultId));
    final cleanedQuery = searchQuery.trim();

    if (cleanedQuery.isNotEmpty) {
      final resultsAsync = ref.watch(
        vaultSearchResultsProvider(
          (
            vaultId: vault.vaultId,
            includeLinks: vault.vaultType == VaultTypes.private,
            query: cleanedQuery,
          ),
        ),
      );

      return resultsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => Text(
          'Unable to search this vault.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.error,
          ),
        ),
        data: (results) => _VaultSearchResultsView(
          results: results,
          query: cleanedQuery,
        ),
      );
    }

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

class _VaultSearchResultsView extends ConsumerWidget {
  const _VaultSearchResultsView({
    required this.results,
    required this.query,
  });

  final VaultSearchResults results;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReadOnly = ref.watch(offlineReadOnlyProvider);

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No Vault results found for "$query".',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEARCH RESULTS',
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        if (results.recipes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Recipes',
            style: AppTextStyles.title.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final result in results.recipes) ...[
            Text(
              result.folder.folderName,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            FolderRecipeRow(
              recipe: result.recipe,
              mutationsEnabled: false,
            ),
            const SizedBox(height: 8),
          ],
        ],
        if (results.links.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'External Links',
            style: AppTextStyles.title.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final link in results.links)
            LinkRow(
              link: link,
              mutationsEnabled: !isReadOnly,
            ),
        ],
      ],
    );
  }
}

// Wraps a centred widget in a scroll view so pull to refresh still triggers
// on the loading, error, and empty states.
class _ScrollableCentre extends StatelessWidget {
  const _ScrollableCentre({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}

class _VaultError extends StatelessWidget {
  const _VaultError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
