import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/cook_timer.dart';

class CookActiveTimer extends StatelessWidget {
  const CookActiveTimer({
    super.key,
    required this.timer,
    required this.now,
    this.compact = false,
  });

  final CookTimer timer;
  final DateTime now;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final remaining = timer.remainingAt(now);
    final total = timer.endsAt.difference(timer.startedAt);
    final progress = total.inMilliseconds <= 0
        ? 0.0
        : (remaining.inMilliseconds / total.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();
    final dimension = compact ? 124.0 : 164.0;
    final ringDimension = dimension - 10;

    return Semantics(
      label: timer.isPaused
          ? '${formatCookTimerClock(remaining)} remaining, paused, on ${timer.label}'
          : '${formatCookTimerClock(remaining)} remaining on ${timer.label}',
      liveRegion: true,
      child: ExcludeSemantics(
        child: SizedBox.square(
          key: Key('cook-active-timer-${timer.notificationId}'),
          dimension: dimension,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.square(
                dimension: ringDimension,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: compact ? 4 : 5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.16),
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    timer.isPaused
                        ? Icons.pause_circle_outline
                        : Icons.timer_outlined,
                    color: AppColors.primary,
                    size: compact ? 20 : 26,
                  ),
                  SizedBox(height: compact ? 5 : 8),
                  SizedBox(
                    width: compact ? 88 : 126,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatCookTimerClock(remaining),
                        key: Key(
                          'cook-active-timer-clock-${timer.notificationId}',
                        ),
                        style: (compact
                                ? AppTextStyles.heading2
                                : AppTextStyles.heading1)
                            .copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 2 : 4),
                  if (timer.isPaused) ...[
                    Text(
                      'Paused',
                      key: Key(
                        'cook-active-timer-paused-${timer.notificationId}',
                      ),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                  ],
                  if (timer.name != null) ...[
                    SizedBox(
                      width: compact ? 92 : 128,
                      child: Text(
                        timer.name!,
                        key: Key(
                          'cook-active-timer-name-${timer.notificationId}',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                  ],
                  Text(
                    'Step ${timer.stepNumber}',
                    key: Key('cook-active-timer-step-${timer.notificationId}'),
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
