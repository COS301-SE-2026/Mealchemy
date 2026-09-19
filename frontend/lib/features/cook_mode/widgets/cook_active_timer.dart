import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/cook_timer.dart';

class CookActiveTimer extends StatelessWidget {
  const CookActiveTimer({
    super.key,
    required this.timer,
    required this.now,
  });

  final CookTimer timer;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final remaining = timer.remainingAt(now);
    final total = timer.endsAt.difference(timer.startedAt);
    final progress = total.inMilliseconds <= 0
        ? 0.0
        : (remaining.inMilliseconds / total.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();

    return Semantics(
      label: '${formatCookTimerClock(remaining)} remaining on ${timer.label}',
      liveRegion: true,
      child: ExcludeSemantics(
        child: SizedBox.square(
          key: const Key('cook-active-timer'),
          dimension: 164,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.square(
                dimension: 154,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.16),
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCookTimerClock(remaining),
                    key: const Key('cook-active-timer-clock'),
                    style: AppTextStyles.heading1.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cooking timer',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
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
