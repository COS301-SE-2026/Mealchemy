import 'package:flutter/material.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/vault_header.dart';
import '../widgets/vault_stats_card.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
      ),
      body: const SafeArea(
        child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VaultHeader(),
                SizedBox(height: 24),
                VaultStatsCard(
                  totalRecipes: 42,
                  createdPercent: 75,
                  categoryCount: 5,
                  optimizationPercent: 60,
                ),
                // The folder list would go here
              ],
            )),
      ),
    );
  }
}
