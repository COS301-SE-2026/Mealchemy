import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/shared_widgets/Organisms/app_navbar.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

import '../providers/vault_provider.dart';
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

class _VaultBody extends StatelessWidget {
  const _VaultBody();

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
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
      child: Text(
        'Unable to load vault.',
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }
}