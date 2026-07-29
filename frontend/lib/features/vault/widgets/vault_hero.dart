import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_icon_button.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'vault_switcher.dart';
import 'shared_vault_strip.dart';

class VaultHero extends StatelessWidget {
  const VaultHero({
    super.key,
    required this.onSearch,
    required this.onAdd,
    required this.onShoppingList,
  });

  final VoidCallback onSearch;
  final VoidCallback onAdd;
  final VoidCallback onShoppingList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left block search, title, switcher
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconButton.ghost(
                  icon: Icons.search,
                  onPressed: onSearch,
                  customColor: AppColors.textLight,
                ),
                const SizedBox(height: 4),
                AppSectionHeader(
                  title: 'Vault',
                  titleStyle: AppTextStyles.heading1.copyWith(
                    color: AppColors.primary,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 8),
                const VaultSwitcher(),
                 const SharedVaultStrip(),
              ],
            ),
          ),
          //Right block add above shopping list
          Column(
            children: [
              AppIconButton.ghost(
                icon: Icons.add,
                onPressed: onAdd,
                customColor: AppColors.textLight,
              ),
              AppIconButton.ghost(
                icon: Icons.receipt_long_outlined,
                onPressed: onShoppingList,
                customColor: AppColors.textLight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}