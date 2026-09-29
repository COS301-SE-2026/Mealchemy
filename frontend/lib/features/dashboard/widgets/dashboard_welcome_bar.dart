import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../meal_plan/models/meal_plan_entry.dart';
import '../../meal_plan/models/meal_slot.dart';
import '../../meal_plan/providers/meal_plan_provider.dart';
import '../../notifications/widgets/notification_bell.dart';
import '../../profile/providers/profile_provider.dart';
import '../../vault/providers/vault_provider.dart';

const _eatingWindow = Duration(minutes: 60);
const _soonWindow = Duration(hours: 3);

({IconData icon, String lead, String highlight}) welcomeMessage(
  List<MealPlanEntry> entries,
  DateTime now,
) {
  DateTime at(MealPlanEntry e) =>
      DateTime(now.year, now.month, now.day, e.mealTime.hour, e.mealTime.minute);

  final today = entries
      .where((e) =>
          e.entryDate.year == now.year &&
          e.entryDate.month == now.month &&
          e.entryDate.day == now.day)
      .toList()
    ..sort((a, b) => at(a).compareTo(at(b)));

  if (today.isEmpty) {
    return (
      icon: Icons.restaurant_menu,
      lead: 'Nothing planned yet',
      highlight: 'What are we cooking today?',
    );
  }

  for (final e in today) {
    final start = at(e);
    final meal = e.mealSlot == MealSlot.snack ? 'meal' : e.mealSlot.label.toLowerCase();
    final label = meal[0].toUpperCase() + meal.substring(1);
    final name = e.displayTitle.isEmpty ? 'Your $meal' : e.displayTitle;

    if (!now.isBefore(start) && now.isBefore(start.add(_eatingWindow))) {
      return (icon: e.mealSlot.icon, lead: 'Enjoy your $meal', highlight: name);
    }

    if (start.isAfter(now)) {
      final until = start.difference(now);
      final when = until <= _soonWindow
          ? 'in ${_formatUntil(until)}'
          : 'at ${MealPlanEntry.formatTime(e.mealTime)}';
      return (icon: e.mealSlot.icon, lead: '$label $when', highlight: name);
    }
  }

  return (
    icon: Icons.check_circle_outline,
    lead: "You're done for today",
    highlight: 'Plan tomorrow?',
  );
}

String _formatUntil(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h == 0) return '${m < 1 ? 1 : m} min';
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

class DashboardWelcomeBar extends ConsumerStatefulWidget {
  const DashboardWelcomeBar({super.key});

  @override
  ConsumerState<DashboardWelcomeBar> createState() => _DashboardWelcomeBarState();
}

class _DashboardWelcomeBarState extends ConsumerState<DashboardWelcomeBar> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    //the message depends on the clock, so recheck it every minute
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(profileProvider).maybeWhen(
          data: (state) {
            final displayName = state.draft.displayName.trim();
            return displayName.isEmpty ? 'Chef' : displayName;
          },
          orElse: () => 'Chef',
        );

    final privateVault = ref.watch(privateVaultProvider);
    final entries = privateVault == null
        ? const <MealPlanEntry>[]
        : ref.watch(mealPlanProvider(privateVault.vaultId)).entries;
    final message = welcomeMessage(entries, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $name',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(message.icon, size: 14, color: AppColors.accentMuted),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        message.lead.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accentMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message.highlight,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const NotificationBell(),
        ],
      ),
    );
  }
}