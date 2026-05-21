import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/shared_widgets/Organisms/app_navbar.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';

import '../providers/vault_provider.dart';
import '../widgets/vault_folder_list.dart';
import '../widgets/vault_quick_strip.dart';
import '../widgets/vault_stats_card.dart';

//Vault screen with the main widgets and layout
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
          return _VaultFoldersLoader(vaultId: vaults.first.vaultId);
        },
      ),
    );
  }
}

class _VaultFoldersLoader extends ConsumerWidget {
  const _VaultFoldersLoader({required this.vaultId});
  final int vaultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(vaultFoldersProvider(vaultId));

    return foldersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _VaultError(message: '$error'),
      data: (folders) => _VaultContent(folders: folders),
    );
  }
}

class _VaultContent extends StatelessWidget {
  const _VaultContent({required this.folders});

  final List<VaultFolder> folders;

  @override
  Widget build(BuildContext context) {
    //TODO: Replace with rael data from provider recipes after merge to dev
    final allRecipes = [
      Recipe(
        recipeId: 1,
        title: 'Pasta Vera',
        cuisineType: 'Italian',
        prepTimeMins: 20,
        cookingTimeMins: 15,
        servingSize: 2,
        photoUrl: null,
      ),
      Recipe(
        recipeId: 2,
        title: 'Carbonara',
        cuisineType: 'Italian',
        prepTimeMins: 15,
        cookingTimeMins: 20,
        servingSize: 2,
        photoUrl: null,
      ),
      Recipe(
        recipeId: 3,
        title: 'Wagyu Skewer',
        cuisineType: 'Japanese',
        prepTimeMins: 30,
        cookingTimeMins: 10,
        servingSize: 1,
        photoUrl: null,
      ),
      Recipe(
        recipeId: 4,
        title: 'Apple Tart',
        cuisineType: 'French',
        prepTimeMins: 40,
        cookingTimeMins: 25,
        servingSize: 4,
        photoUrl: null,
      ),
    ];

    return CustomScrollView(
      slivers: [
        //Gradient hero app bar
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.brand,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Top row - title + camera
                      Row(
                        children: [
                          Text(
                            'MY VAULT',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.accent,
                              letterSpacing: 2,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.textDark,
                              size: 22,
                            ),
                            tooltip: 'Scan recipe',
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.search,
                              color: AppColors.textDark,
                              size: 22,
                            ),
                            tooltip: 'Search vault',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Vault title with gold accent
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Vault',
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.textDark,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 32,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your personal recipe collection',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Body content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats card
                VaultStatsCard(
                  totalRecipes: 10,
                  createdPercent: 84,
                  categoryCount: 6,
                  optimizationPercent: 72,
                ),
                const SizedBox(height: 28),

                // Gold divider section label
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Let's cook it!",
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Quick recipe strip
                VaultQuickStrip(recipes: allRecipes),
                const SizedBox(height: 28),

                // Private vault section
                VaultFolderList(folders: folders),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VaultError extends StatelessWidget {
  const _VaultError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Unable to load vault.',
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }
}
