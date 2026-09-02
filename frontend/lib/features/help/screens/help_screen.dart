import 'package:flutter/material.dart';

import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/theme/app_colours.dart';
import '../widgets/help_content_blocks.dart';
import '../widgets/help_row.dart';
import '../widgets/help_header.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HelpHeader(),
              const SizedBox(height: 32),

              const _Section(title: 'Help Center'),
              const SizedBox(height: 12),
              const HelpRow(
                icon: Icons.mail_outline_rounded,
                title: 'Contact Support',
                body: [
                  HelpBodyText(
                    'Reach our team for help with your queries.',
                  ),
                  HelpBodyText(
                    'Our contacts:',
                  ),
                  SizedBox(height: 10),
                  HelpIconRow(
                    icon: Icons.mail_outline_rounded,
                    value: 'pulsefve@gmail.com',
                  ),
                  HelpIconRow(
                    icon: Icons.phone,
                    value: '0840941479',
                  ),
                  SizedBox(height: 10),
                  HelpBodyText(
                    'Available times:',
                  ),
                  SizedBox(height: 5),
                  HelpIconRow(
                    icon: Icons.schedule_rounded,
                    value: 'Mon to Fri, 9:00 to 17:00',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.flag_outlined,
                title: 'Report a Problem',
                body: [
                  HelpBodyText(
                    'Spotted a bug or an incorrect recipe? Let us know so we can fix it.',
                  ),
                  SizedBox(height: 10),
                  HelpBodyText(
                    'To report a bug or incorrect recipe, email us a short description and a screenshot if you can:',
                  ),
                  SizedBox(height: 10),
                  HelpIconRow(
                    icon: Icons.mail_outline_rounded,
                    value: 'pulsefve@gmail.com',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const _Section(title: 'Navigation Guide'),
              const SizedBox(height: 12),
              const HelpRow(
                icon: Icons.kitchen_outlined,
                title: 'Getting to know your Pantry',
                body: [
                  HelpBodyText(
                    'Your Pantry is a living snapshot of everything you have on hand, right down to how fresh it still is.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is your quick tour of the Pantry screen:',
                  ),
                  HelpIconBullet(
                    icon: Icons.search,
                    text:
                        'Use the search bar to jump straight to an ingredient.',
                  ),
                  HelpIconBullet(
                    icon: Icons.filter_alt_outlined,
                    text:
                        'The category chips let you filter your pantry down to just Vegetables, Dairy, or whichever group you are after.',
                  ),
                  HelpIconBullet(
                    icon: Icons.insights_outlined,
                    text:
                        'The summary card gives you the full picture: how many items you have, their overall freshness, and a Meal Optimisation '
                        'score showing how well-stocked you are to cook from your pantry alone.',
                  ),
                  HelpIconBullet(
                    icon: Icons.edit_outlined,
                    text:
                        'Tap the pencil on any item to edit its quantity or details.',
                  ),
                  HelpIconBullet(
                    icon: Icons.add,
                    text:
                        'The plus button adds a new item to your pantry whenever you '
                        'need to.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.bookmark_border,
                title: 'Vaults',
                body: [
                  HelpBodyText(
                    'Think of your Vault as your personal recipe kitchen. The moment you join, we hand you a Private Vault with a folder ready to catch '
                    'every recipe you create. It stays yours alone, until you decide to move it somewhere new.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Cooking is better together, so you can spin up Shared Vaults too. Invite your family, your flatmates, your foodie friends, and build '
                    'as many shared collections as you like, each with its own crew.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is your quick tour of the Vault screen:',
                  ),
                  HelpIconBullet(
                    icon: Icons.keyboard_arrow_down_rounded,
                    text:
                        'Tap the little arrow by the vault name to hop between your Private and Shared vaults.',
                  ),
                  HelpIconBullet(
                    icon: Icons.people_outline,
                    text:
                        'Spot the people icon? That is your Shared Vaults, where you add friends and manage who is in.',
                  ),
                  HelpIconBullet(
                    icon: Icons.add,
                    text:
                        'Hit the plus to drop in a new recipe, or Add Vault to start a fresh shared collection.',
                  ),
                  HelpIconBullet(
                    icon: Icons.more_vert,
                    text:
                        'Tap the three dots for the good stuff: create, add, and tidy up your vaults and folders.',
                  ),
                  HelpIconBullet(
                    icon: Icons.shopping_cart_outlined,
                    text:
                        'Tap the cart and your shopping list is ready to roll.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.explore_outlined,
                title: 'Guided Discovery',
                body: [
                  HelpBodyText(
                    'Guided Discovery helps you find recipes that match your '
                    'tastes and the ingredients you have available.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Browse the recommended recipes and respond to each one '
                    'to help Mealchemy learn what you enjoy.',
                  ),
                  HelpIconBullet(
                    icon: Icons.favorite_border,
                    text:
                        'Like recipes that interest you to improve future recommendations.',
                  ),
                  HelpIconBullet(
                    icon: Icons.close_rounded,
                    text:
                        'Skip recipes that are not for you and continue discovering new options.',
                  ),
                  HelpIconBullet(
                    icon: Icons.tune_rounded,
                    text:
                        'Your pantry and saved food preferences help shape the recipes you see.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.monitor_heart_outlined,
                title: 'Understanding Nutrition',
                body: [
                  HelpBodyText(
                    'Open the Nutrition tab on a recipe to view its estimated '
                    'nutritional information.',
                  ),
                  SizedBox(height: 8),
                  HelpIconBullet(
                    icon: Icons.swap_horiz_rounded,
                    text:
                        'Switch between values for the full recipe and values per serving.',
                  ),
                  HelpIconBullet(
                    icon: Icons.pie_chart_outline_rounded,
                    text:
                        'View calories, protein, carbohydrates, fat, fibre, and sodium.',
                  ),
                  HelpIconBullet(
                    icon: Icons.expand_more_rounded,
                    text:
                        'Expand an ingredient to see how it contributes to the recipe totals.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Nutritional values are estimates based on data provided '
                    'by USDA FoodData Central and may not be completely accurate.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.link_rounded,
                title: 'Saving External Recipe Links',
                body: [
                  HelpBodyText(
                    'The External Links folder in your Vault keeps recipe '
                    'links from outside Mealchemy together in one place.',
                  ),
                  SizedBox(height: 8),
                  HelpIconBullet(
                    icon: Icons.bookmark_add_outlined,
                    text:
                        'Save an external recipe link so you can easily return to it later.',
                  ),
                  HelpIconBullet(
                    icon: Icons.open_in_new_rounded,
                    text:
                        'Open a saved link to view the recipe on its original website.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.cloud_off_outlined,
                title: 'Using Mealchemy Offline',
                body: [
                  HelpBodyText(
                    'When you lose your connection, Mealchemy can still show '
                    'content that was previously saved to your device.',
                  ),
                  SizedBox(height: 8),
                  HelpIconBullet(
                    icon: Icons.visibility_outlined,
                    text:
                        'Browse cached recipes, Vaults, Discover, Pantry, and Shopping Lists while offline.',
                  ),
                  HelpIconBullet(
                    icon: Icons.info_outline_rounded,
                    text:
                        'The offline banner and freshness labels show when you are viewing cached information.',
                  ),
                  HelpIconBullet(
                    icon: Icons.edit_off_outlined,
                    text:
                        'Changes such as creating, editing, deleting, favouriting, checking items, and updating your pantry are unavailable offline.',
                  ),
                  HelpIconBullet(
                    icon: Icons.wifi_rounded,
                    text:
                        'Online controls become available again after Mealchemy reconnects to the backend.',
                  ),
                ],
              ),

              const HelpRow(
                icon: Icons.restaurant_menu_rounded,
                title: 'Viewing a recipe',
                body: [
                  HelpBodyText(
                    'Every recipe has a home of its own. Tap any card and you will land on its details page, your one-stop view for everything about that dish before you cook it.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is your quick tour of the recipe details screen:',
                  ),
                  HelpIconBullet(
                    icon: Icons.arrow_back_ios_new,
                    text:
                        'The back arrow always brings you home to wherever you came from.',
                  ),
                  HelpIconBullet(
                    icon: Icons.bookmark_border,
                    text:
                        'Fallen for this dish? Tap the bookmark and tuck it away in whichever Vault it belongs in.',
                  ),
                  HelpIconBullet(
                    icon: Icons.add_shopping_cart_rounded,
                    text:
                        'Tap the cart and we will check what is already in your pantry, then build a shopping list of whatever you are missing.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Just below the photo sits your Overview, Ingredients, Steps, and Nutrition, each a swipe away from the next.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'When you are ready, Start Cooking walks you through the recipe step by step, ticking ingredients off your pantry as you go.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.list_alt_rounded,
                title: 'Managing your Shopping Lists',
                body: [
                  HelpBodyText(
                    'Every list you have created lives here, ready whenever you need to pop out for ingredients.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is your quick tour of the Shopping Lists screen:',
                  ),
                  HelpIconBullet(
                    icon: Icons.list_alt_rounded,
                    text:
                        'Tap any list to open it up and see everything on it, grouped by category to make shopping easier.',
                  ),
                  HelpIconBullet(
                    icon: Icons.more_vert,
                    text:
                        'The three dots next to a list let you rename it or delete it '
                        'altogether.',
                  ),
                  HelpIconBullet(
                    icon: Icons.add,
                    text:
                        'The plus button, top and bottom, starts a brand new list whenever the mood strikes.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Once you are inside a list, tick off items as you shop, or use Select All and Deselect to speed things along.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'When you are done, tap Update Pantry and everything you have ticked moves straight into your pantry and off the list.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.play_circle_outline_rounded,
                title: 'Video tutorials',
                body: [
                  HelpBodyText(
                    'Prefer to watch? Our short video walkthroughs cover the main features.',
                  ),
                  SizedBox(height: 10),
                  HelpIconRow(
                    icon: Icons.link_rounded,
                    value: 'mealchemy.com/tutorials',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              //Frequently
              const _Section(title: 'Frequently Asked'),
              const SizedBox(height: 12),
              const HelpRow(
                icon: Icons.help_outline_rounded,
                title: 'How do I add ingredients to my pantry?',
                body: [
                  HelpBodyText(
                    'Open the Pantry tab, tap the plus button, search the ingredient catalogue, choose a quantity and unit, and save.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.help_outline_rounded,
                title: 'How do I share a vault with a friend?',
                body: [
                  HelpBodyText(
                    'Open a shared vault you own, choose to add a member, and enter your friend\'s email address. They will then see the '
                    'shared vault and its recipes.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.help_outline_rounded,
                title: 'How are recipe recommendations generated?',
                body: [
                  HelpBodyText(
                    'Recommendations are based on the ingredients in your pantry, your saved food preferences, and the recipes you '
                    'like or skip while swiping.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.help_outline_rounded,
                title: 'How do I generate a shopping list from a recipe?',
                body: [
                  HelpBodyText(
                    'Open a recipe and generate a shopping list. Mealchemy compares the recipe ingredients with your pantry and adds '
                    'only the items you are missing.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.help_outline_rounded,
                title: 'Is my data private?',
                body: [
                  HelpBodyText(
                    'Your account, pantry, and preferences are tied to your profile and are not shared with other users, except for '
                    'vaults you choose to share.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//section header, padded to match the screen gutters
class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppSectionHeader(title: title),
    );
  }
}
