import 'package:flutter/material.dart';

import '../../cook_mode/models/cook_timer.dart';
import '../../cook_mode/widgets/cook_active_timer.dart';

class DashboardActiveTimers extends StatelessWidget {
  const DashboardActiveTimers({
    super.key,
    required this.timers,
    required this.now,
    required this.onTimerTap,
  });

  final List<CookTimer> timers;
  final DateTime now;
  final ValueChanged<CookTimer> onTimerTap;

  @override
  Widget build(BuildContext context) {
    if (timers.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    return Padding(
      key: const Key('dashboard-active-timers'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active cooking timers',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 158,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: timers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final timer = timers[index];
                return Semantics(
                  button: true,
                  label: 'Open ${timer.recipeTitle}, step ${timer.stepNumber}',
                  child: InkWell(
                    key: Key('dashboard-timer-${timer.notificationId}'),
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onTimerTap(timer),
                    child: SizedBox(
                      width: 132,
                      child: Column(
                        children: [
                          CookActiveTimer(
                            timer: timer,
                            now: now,
                            compact: true,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timer.recipeTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
