import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/shared_widgets/Organisms/app_navbar.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/flavour_profile_card.dart';
import '../widgets/preference_option_card.dart';
import '../widgets/preference_tag_chip.dart';

class PreferenceScreen extends StatelessWidget {
  const PreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary mock data until preferences API is connected.
    final selectedAllergies = ['PEANUTS', 'SHELLFISH'];
    final availableAllergies = ['TREE NUTS', 'SOY', 'EGGS'];
    final dislikedIngredients = ['CILANTRO', 'CAPERS', 'BLUE CHEESE'];

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      bottomNavigationBar: AppNavbar(
        currentRoute: AppRoutes.preference,
        onRouteSelected: (route) => context.go(route),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Text(
              'PERSONALIZED CURATION',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Bespoke Culinary\nProfile',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.primary,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Fine-tune your Mealchemy journey by defining the boundaries of your palate. Our curators use these directives to tailor every recommendation to your specific lifestyle.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 32),

            // Dietary selection cards.
            const AppSectionHeader(title: 'Dietary Directives'),
            const SizedBox(height: 14),
            const PreferenceOptionCard(
              title: 'PLANT-BASED / VEGAN',
              subtitle: 'Exclusively botanical-led cuisine.',
            ),
            const SizedBox(height: 10),
            const PreferenceOptionCard(
              title: 'CELIAC FRIENDLY / GLUTEN-FREE',
              subtitle: 'Rigorous gluten-free adherence.',
              selected: true,
            ),
            const SizedBox(height: 10),
            const PreferenceOptionCard(
              title: 'DAIRY FREE',
              subtitle: 'Lactose and casein-free alternatives.',
            ),
            const SizedBox(height: 10),
            const PreferenceOptionCard(
              title: 'CARB CONSCIOUS / KETO',
              subtitle: 'High protein and healthy fats focus.',
            ),
            const SizedBox(height: 32),

            // Allergy and dislike tags.
            const AppSectionHeader(title: 'Critical Allergies'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...selectedAllergies.map(
                  (allergy) => PreferenceTagChip(
                    label: allergy,
                    selected: true,
                    onRemove: () {},
                  ),
                ),
                ...availableAllergies.map(
                  (allergy) => PreferenceTagChip(
                    label: allergy,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const AppSectionHeader(title: 'Aversions & Dislikes'),
            const SizedBox(height: 14),
            AppTextField(
              hint: 'Add an ingredient...',
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
                tooltip: 'Add ingredient',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dislikedIngredients
                  .map(
                    (ingredient) => PreferenceTagChip(
                      label: ingredient,
                      selected: true,
                      onRemove: () {},
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),

            //cuisine preference cards
            const AppSectionHeader(title: 'Flavour Profiles'),
            const SizedBox(height: 16),
            const FlavourProfileCard(
              label: 'Mediterranean',
              description: 'Bright herbs, olive oil, citrus, grains, and fresh vegetables.',
              icon: Icons.local_florist_outlined,
              selected: true,
            ),
            const SizedBox(height: 12),
            const FlavourProfileCard(
              label: 'Asian Fusion',
              description: 'Soy, ginger, chilli, sesame, rice bowls, noodles, and umami-rich sauces.',
              icon: Icons.ramen_dining_outlined,
            ),
            const SizedBox(height: 12),
            const FlavourProfileCard(
              label: 'Comfort Classics',
              description: 'Warm, familiar meals with hearty textures and simple pantry staples.',
              icon: Icons.soup_kitchen_outlined,
            ),
            const SizedBox(height: 12),
            const FlavourProfileCard(
              label: 'Fresh & Light',
              description: 'Lean proteins, crisp produce, lighter sauces, and balanced portions.',
              icon: Icons.eco_outlined,
            ),
            const SizedBox(height: 40),
            AppButton(
              label: 'Update Profile',
              onPressed: () {},
            ),
            const SizedBox(height: 14),
            AppButton(
              label: 'Reset All Directives',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}