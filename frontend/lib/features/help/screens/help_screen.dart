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
                icon: Icons.home_outlined,
                title: 'Getting to know your Home',
                body: [
                  HelpBodyText(
                    'Home is your kitchen at a glance, with your pantry, fresh recipe ideas, and the meals you have planned all in one place.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is your quick tour of the Home screen:',
                  ),
                  HelpIconBullet(
                    icon: Icons.notifications_none_rounded,
                    text:
                        'The bell beside your greeting keeps you in the loop on vault invites and anything else that needs you.',
                  ),
                  HelpIconBullet(
                    icon: Icons.add,
                    text:
                        'The In Your Pantry card shows how many ingredients you have on hand. Tap the plus to add a new one without leaving Home.',
                  ),
                  HelpIconBullet(
                    icon: Icons.lightbulb_outline,
                    text:
                        'The Smart Suggestion card reminds you how many items are still waiting on your shopping list.',
                  ),
                  HelpIconBullet(
                    icon: Icons.refresh_rounded,
                    text:
                        'Pull down on the screen whenever you want everything freshly updated.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.auto_awesome_outlined,
                title: 'Recommended for You',
                body: [
                  HelpBodyText(
                    'Swipe sideways through recipes picked just for you, shaped by what is in your pantry, your food preferences, and the recipes you have liked.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is what each card tells you:',
                  ),
                  HelpIconBullet(
                    icon: Icons.check_circle,
                    text:
                        'The match badge shows how well the recipe suits you. The higher the number, the better the fit.',
                  ),
                  HelpIconBullet(
                    icon: Icons.schedule_rounded,
                    text: 'The clock gives you the total time to get it on the table.',
                  ),
                  HelpIconBullet(
                    icon: Icons.shopping_basket_outlined,
                    text:
                        'The basket shows how many ingredients you still need to buy, or Ready to cook when you already have everything.',
                  ),
                  HelpIconBullet(
                    icon: Icons.touch_app_outlined,
                    text: 'Tap any card to open the full recipe.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.calendar_month_outlined,
                title: 'Getting around your Meal Plan',
                body: [
                  HelpBodyText(
                    'Your Meal Plan lays out breakfast, lunch, and dinner for each day, sorted by the time you plan to eat.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is your quick tour of the Meal Plan:',
                  ),
                  HelpIconBullet(
                    icon: Icons.keyboard_arrow_down_rounded,
                    text:
                        'Tap the arrow next to My Plan to hop between your own plan and the plans of your shared vaults.',
                  ),
                  HelpIconBullet(
                    icon: Icons.chevron_right_rounded,
                    text:
                        'Use the arrows either side of the date to step through the days.',
                  ),
                  HelpIconBullet(
                    icon: Icons.calendar_today_outlined,
                    text:
                        'Tap the date to jump to any day on the calendar. Back to Today brings you straight home again.',
                  ),
                  HelpIconBullet(
                    icon: Icons.auto_awesome,
                    text:
                        'A little sparkle next to a meal means Mealchemy suggested it for you.',
                  ),
                  HelpIconBullet(
                    icon: Icons.visibility_outlined,
                    text:
                        'See View Only on a shared plan? You can look through it, but only the owner and editors can make changes.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.restaurant_menu_rounded,
                title: 'Planning your day',
                body: [
                  HelpBodyText(
                    'Filling in your day only takes a few taps, and every meal can be changed whenever plans do.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is how to plan your meals:',
                  ),
                  HelpIconBullet(
                    icon: Icons.add,
                    text:
                        'Tap Add on an empty breakfast, lunch, or dinner to plan that meal.',
                  ),
                  HelpIconBullet(
                    icon: Icons.restaurant_outlined,
                    text:
                        'Want something extra, like a snack? Another Meal lets you add it to the day.',
                  ),
                  HelpIconBullet(
                    icon: Icons.edit_outlined,
                    text:
                        'Tap the pencil on a meal to swap the recipe, change the time, add a note, or remove it altogether.',
                  ),
                  HelpIconBullet(
                    icon: Icons.more_vert,
                    text:
                        'Tap the three dots for more: add a meal, generate a shopping list from your plan, or clear the whole day.',
                  ),
                  HelpIconBullet(
                    icon: Icons.shopping_cart_outlined,
                    text:
                        'Generate shopping list lets you pick a start and end date, then gathers the ingredients for every meal in between.',
                  ),
                ],
              ),
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
                    'Guided Discovery is where you find your next favourite meal. Every recipe is picked for you, and every swipe teaches Mealchemy a little more about what you love.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is your quick tour of the Discover screen:',
                  ),
                  HelpIconBullet(
                    icon: Icons.tune,
                    text:
                        'Tap the sliders at the top left to fine-tune how your recommendations are chosen.',
                  ),
                  HelpIconBullet(
                    icon: Icons.shopping_cart_outlined,
                    text:
                        'The cart at the top right takes you to your shopping lists, and the badge shows how many you have.',
                  ),
                  HelpIconBullet(
                    icon: Icons.filter_alt_outlined,
                    text:
                        'Scroll through the chips to narrow things down. Quick keeps it to meals ready in 30 minutes or less, or pick a diet like Vegetarian, Vegan, or Pescatarian.',
                  ),
                  HelpIconBullet(
                    icon: Icons.favorite,
                    text:
                        'Love the look of it? Tap the heart or swipe right to like it and save it to your Favourites.',
                  ),
                  HelpIconBullet(
                    icon: Icons.close_rounded,
                    text: 'Not for you? Tap the cross or swipe left to pass.',
                  ),
                  HelpIconBullet(
                    icon: Icons.skip_next_rounded,
                    text:
                        'Not sure yet? The middle button skips it for now without counting against it.',
                  ),
                  HelpIconBullet(
                    icon: Icons.refresh_rounded,
                    text:
                        'Seen everything? You will get a summary of your likes, passes, and skips, and Start Again or a pull down brings in a fresh batch.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.tune,
                title: 'Tuning your recommendations',
                body: [
                  HelpBodyText(
                    'You decide what matters most when Mealchemy picks your recipes. Tap the sliders on the Discover screen to open your Recommendations settings.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Slide each one up to give it more weight:',
                  ),
                  HelpIconBullet(
                    icon: Icons.kitchen_outlined,
                    text:
                        'Pantry Match favours recipes you can make with what you already have.',
                  ),
                  HelpIconBullet(
                    icon: Icons.public,
                    text:
                        'Cuisine leans towards the cuisines you cook and swipe on most.',
                  ),
                  HelpIconBullet(
                    icon: Icons.monitor_heart_outlined,
                    text:
                        'Nutrition pushes recipes that match your nutritional goals.',
                  ),
                  HelpIconBullet(
                    icon: Icons.eco_outlined,
                    text:
                        'Freshness prioritises ingredients that are close to their expiry date.',
                  ),
                  HelpIconBullet(
                    icon: Icons.auto_awesome,
                    text:
                        'Novelty brings in more variety instead of the familiar favourites.',
                  ),
                  HelpIconBullet(
                    icon: Icons.restart_alt_rounded,
                    text:
                        'Tap Save Changes when you are happy, or use the reset button at the top to go back to the defaults.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.menu_book_outlined,
                title: 'Taking a closer look at a recipe',
                body: [
                  HelpBodyText(
                    'Each card gives you the essentials at a glance, and a full preview is only a tap away.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is what each card tells you:',
                  ),
                  HelpIconBullet(
                    icon: Icons.check_circle,
                    text:
                        'The match badge shows how well the recipe suits you. The higher the number, the better the fit.',
                  ),
                  HelpIconBullet(
                    icon: Icons.shopping_basket_outlined,
                    text:
                        'The basket line lists the ingredients you are still missing.',
                  ),
                  HelpIconBullet(
                    icon: Icons.schedule_rounded,
                    text: 'The clock shows the total time from start to plate.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Tap View Full Recipe on a card to open its preview:',
                  ),
                  HelpIconBullet(
                    icon: Icons.timer_outlined,
                    text:
                        'See the prep, cook, and total time, plus how many people it serves.',
                  ),
                  HelpIconBullet(
                    icon: Icons.auto_awesome,
                    text:
                        'Why this matches you explains the pick, from how well it fits your goals to a New tag for recipes you have not tried yet.',
                  ),
                  HelpIconBullet(
                    icon: Icons.shopping_basket_outlined,
                    text:
                        'You are missing lists every ingredient you would still need to buy.',
                  ),
                  HelpIconBullet(
                    icon: Icons.keyboard_arrow_down_rounded,
                    text:
                        'Swipe the preview down, or tap Close Preview or Looks Good, to get back to swiping.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.play_circle_outline_rounded,
                title: 'Sizzles',
                body: [
                  HelpBodyText(
                    'Sizzles brings recipes to life with short cooking videos. Tap Sizzles next to Discover and scroll through for a little inspiration.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is your quick tour of Sizzles:',
                  ),
                  HelpIconBullet(
                    icon: Icons.bookmark_border,
                    text:
                        'Tap Save to keep the recipe in your Vault so you can find it again.',
                  ),
                  HelpIconBullet(
                    icon: Icons.volume_off_outlined,
                    text:
                        'Videos start muted. Tap Unmute to hear the sizzle.',
                  ),
                  HelpIconBullet(
                    icon: Icons.menu_book_outlined,
                    text: 'Tap Recipe to open the full recipe and start cooking.',
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
                icon: Icons.restaurant,
                title: 'Cooking step by step',
                body: [
                  HelpBodyText(
                    'Start Cooking turns your recipe into a calm, one step at a time guide, so you can keep your eyes on the pan instead of the phone.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is your quick tour of Cook Mode:',
                  ),
                  HelpIconBullet(
                    icon: Icons.linear_scale_rounded,
                    text:
                        'The bar at the top shows how far along you are, like Step 1 of 3. Each step appears in big, easy-to-read text.',
                  ),
                  HelpIconBullet(
                    icon: Icons.volume_up_outlined,
                    text:
                        'Mealchemy reads each step aloud and highlights the words as it goes. Tap Pause to hold it, Resume to carry on, or Replay to hear it again.',
                  ),
                  HelpIconBullet(
                    icon: Icons.speed_rounded,
                    text:
                        'Tap the speed at the top right to change how fast the step is read to you.',
                  ),
                  HelpIconBullet(
                    icon: Icons.mic,
                    text:
                        'Hands covered in flour? Tap Speak, then say “next”, “back”, or “repeat” to move around without touching your screen. Tap it again to turn voice off.',
                  ),
                  HelpIconBullet(
                    icon: Icons.arrow_forward,
                    text:
                        'Use Back and Next to move between steps. On the last step, Next becomes Finish.',
                  ),
                  HelpIconBullet(
                    icon: Icons.close_rounded,
                    text:
                        'Need to step away? Tap the cross at the top left to leave. Continue cooking on your Home screen takes you straight back to the step you were on.',
                  ),
                ],
              ),
              const HelpRow(
                icon: Icons.timer_outlined,
                title: 'Using cooking timers',
                body: [
                  HelpBodyText(
                    'Never overcook the pasta again. Set a timer right inside Cook Mode and Mealchemy keeps count for you.',
                  ),
                  SizedBox(height: 8),
                  HelpBodyText(
                    'Here is how timers work:',
                  ),
                  HelpIconBullet(
                    icon: Icons.timer_outlined,
                    text:
                        'When a step mentions a time, a quick Start button for that timer appears near the bottom of the screen. Tap it and you are off.',
                  ),
                  HelpIconBullet(
                    icon: Icons.more_time,
                    text:
                        'Tap the timer icon at the bottom right to set your own. Give it a name if you like, pick the minutes with the plus and minus buttons, and tap Start timer.',
                  ),
                  HelpIconBullet(
                    icon: Icons.donut_large_rounded,
                    text:
                        'Your running timer shows as a ring on the step, counting down with its name and the step it belongs to.',
                  ),
                  HelpIconBullet(
                    icon: Icons.layers_outlined,
                    text:
                        'Cooking a few things at once? You can run several timers together, each with its own name.',
                  ),
                  HelpIconBullet(
                    icon: Icons.pause,
                    text:
                        'Open the timer menu to pause, resume, or cancel any timer under Active.',
                  ),
                  HelpIconBullet(
                    icon: Icons.notifications_none_rounded,
                    text:
                        'Timers keep running when you leave Cook Mode, and you will see them on your Home screen. Allow notifications so Mealchemy can let you know when time is up, even with your phone locked.',
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
