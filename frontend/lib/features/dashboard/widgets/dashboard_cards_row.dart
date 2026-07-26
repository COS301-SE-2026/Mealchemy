import 'package:flutter/material.dart';
import 'package:mealchemy/features/dashboard/widgets/dashboard_pantry_card.dart';
import 'package:mealchemy/features/dashboard/widgets/smart_suggestion_card.dart';

class DashboardCardsRow extends StatelessWidget {
  const DashboardCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Expanded(
              flex: 5,
              child: DashboardPantryCard(),
            ),

            SizedBox(width: 12),

            Expanded(
              flex: 4,
              child: SmartSuggestionCard(),
            ),
          ],
        ),
      ),
    );
  }
}