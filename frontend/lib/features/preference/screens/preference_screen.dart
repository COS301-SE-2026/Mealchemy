import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/shared_widgets/Organisms/app_navbar.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/user_preferences.dart';
import '../providers/preference_provider.dart';
import '../widgets/flavour_profile_card.dart';
import '../widgets/preference_option_card.dart';
import '../widgets/preference_tag_chip.dart';

//had to put ConsumerWidget to let screen read Riverpod providers 
class PreferenceScreen extends ConsumerWidget {
  const PreferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //loads mock/API data
    final preferencesState = ref.watch(userPreferencesProvider);

    //handles the diff states
    return preferencesState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Preference')),
        body: Center(
          child: Text(
            'Unable to load preferences.',
            style: AppTextStyles.body.copyWith(color: AppColors.error),
          ),
        ),
      ),
      data: (preferences) => _PreferenceContent(preferences: preferences),
    );
  }
}

class _PreferenceContent extends StatelessWidget {
  const _PreferenceContent({required this.preferences});

  final UserPreferences preferences;

  @override
  Widget build(BuildContext context) {
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
            ...preferences.dietaryDirectives.map(
              (directive) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PreferenceOptionCard(
                  title: directive.title,
                  subtitle: directive.subtitle,
                  selected: directive.selected,
                  onTap: () {},
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Allergy and dislike tags.
            const AppSectionHeader(title: 'Critical Allergies'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...preferences.selectedAllergies.map(
                  (allergy) => PreferenceTagChip(
                    label: allergy,
                    selected: true,
                    onRemove: () {},
                  ),
                ),
                ...preferences.availableAllergies.map(
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
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: preferences.dislikedIngredients
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

            // Cuisine preference cards.
            const AppSectionHeader(title: 'Flavour Profiles'),
            const SizedBox(height: 16),
            ...preferences.flavourProfiles.map(
              (profile) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FlavourProfileCard(
                  label: profile.label,
                  description: profile.description,
                  icon: _iconForFlavourProfile(profile.iconKey),
                  selected: profile.selected,
                  onTap: () {},
                ),
              ),
            ),
            const SizedBox(height: 28),
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

// Maps mock/API icon keys to visual icons.
IconData _iconForFlavourProfile(String iconKey) {
  return switch (iconKey) {
    'mediterranean' => Icons.local_florist_outlined,
    'asian' => Icons.ramen_dining_outlined,
    'comfort' => Icons.soup_kitchen_outlined,
    'fresh' => Icons.eco_outlined,
    _ => Icons.restaurant_menu_outlined,
  };
}