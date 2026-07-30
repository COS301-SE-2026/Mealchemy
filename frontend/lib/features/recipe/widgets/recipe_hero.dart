import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recipe.dart';
import 'save_to_vault_sheet.dart';
import '../../shopping_lists/providers/shopping_list_provider.dart';

//image with overlay, back/share buttons, recipe title
class RecipeHero extends ConsumerWidget {
  const RecipeHero({super.key, required this.recipe, this.height = 290});

  final Recipe recipe;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _HeroImage(photoUrl: recipe.photoUrl),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.heroScrim),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _HeroCircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => context.pop(),
                      background:
                          AppColors.surfaceWhite.withValues(alpha: 0.95),
                      iconColor: AppColors.textLight,
                      frosted: false,
                    ),
                    const Spacer(),
                    _HeroCircleButton(
                      icon: Icons.add_shopping_cart,
                      onTap: () => _generateShoppingList(context, ref),
                      background: AppColors.textLight.withValues(alpha: 0.45),
                      iconColor: AppColors.textDark,
                      frosted: true,
                    ),
                    const SizedBox(width: 10),
                    _HeroCircleButton(
                      icon: Icons.bookmark_add_outlined,
                      onTap: () => showSaveToVaultSheet(
                        context: context,
                        ref: ref,
                        recipeId: recipe.recipeId,
                      ),
                      background: AppColors.textLight.withValues(alpha: 0.45),
                      iconColor: AppColors.textDark,
                      frosted: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Text(
              recipe.title,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.textDark,
                fontSize: 30,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //generates a shopping list from this recipe's missing pantry items
  Future<void> _generateShoppingList(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(shoppingListsProvider.notifier).generateFromRecipe(
            recipeId: recipe.recipeId,
            recipeName: recipe.title,
          );
      ref.invalidate(shoppingListsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Shopping list created for ${recipe.title}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not create shopping list. Try again.'),
        ),
      );
    }
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null) {
      return Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _HeroPlaceholder(),
      );
    }
    return const _HeroPlaceholder();
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandOverlay),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          color: AppColors.accent,
          size: 72,
        ),
      ),
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({
    required this.icon,
    required this.onTap,
    required this.background,
    required this.iconColor,
    this.frosted = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color iconColor;
  final bool frosted;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
      ),
      child: Icon(icon, color: iconColor, size: 19),
    );

    return GestureDetector(
      onTap: onTap,
      child: frosted
          ? ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: button,
              ),
            )
          : button,
    );
  }
}