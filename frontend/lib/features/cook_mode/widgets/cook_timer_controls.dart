import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/cook_timer.dart';
import '../providers/cook_timer_provider.dart';

class CookTimerControls extends StatelessWidget {
  const CookTimerControls({
    super.key,
    required this.state,
    required this.suggestedDuration,
    required this.onStart,
    required this.onCancel,
  });

  final CookTimerState state;
  final Duration? suggestedDuration;
  final Future<void> Function(Duration duration) onStart;
  final Future<void> Function(CookTimer timer) onCancel;

  @override
  Widget build(BuildContext context) {
    final activeTimers = state.activeTimers;
    final nextTimer = activeTimers.firstOrNull;
    final summary = nextTimer == null
        ? 'No active timers'
        : '${formatCookDuration(nextTimer.remainingAt(state.now))} · ${nextTimer.label}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  summary,
                  key: const Key('cook-timer-summary'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (suggestedDuration != null)
                TextButton(
                  key: const Key('start-suggested-timer'),
                  onPressed: () => unawaited(onStart(suggestedDuration!)),
                  child:
                      Text('Start ${formatCookDuration(suggestedDuration!)}'),
                ),
              IconButton(
                key: const Key('manage-cook-timers'),
                tooltip: 'Manage cooking timers',
                onPressed: () => _showTimerSheet(context, activeTimers),
                icon: const Icon(Icons.more_time),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        if (state.warningMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: Text(
              state.warningMessage!,
              key: const Key('cook-timer-warning'),
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Future<void> _showTimerSheet(
    BuildContext context,
    List<CookTimer> activeTimers,
  ) async {
    var minutes = 10.0;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: FractionallySizedBox(
              heightFactor: 0.72,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Cooking timers', style: AppTextStyles.title),
                    const SizedBox(height: 18),
                    Text(
                      '${minutes.round()} minutes',
                      key: const Key('manual-timer-duration'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading2,
                    ),
                    Slider(
                      key: const Key('manual-timer-slider'),
                      min: 1,
                      max: 180,
                      divisions: 179,
                      value: minutes,
                      label: '${minutes.round()} min',
                      onChanged: (value) {
                        setSheetState(() => minutes = value);
                      },
                    ),
                    AppButton.primary(
                      key: const Key('start-manual-timer'),
                      label: 'Start timer',
                      leftIcon: Icons.timer_outlined,
                      onPressed: () async {
                        await onStart(Duration(minutes: minutes.round()));
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 20),
                    Text('Active', style: AppTextStyles.bodyBold),
                    const SizedBox(height: 8),
                    Expanded(
                      child: activeTimers.isEmpty
                          ? Center(
                              child: Text(
                                'No active timers',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: activeTimers.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final timer = activeTimers[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.timer_outlined),
                                  title: Text(timer.label),
                                  subtitle: Text(
                                    formatCookDuration(
                                      timer.remainingAt(state.now),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Cancel ${timer.label}',
                                    onPressed: () async {
                                      await onCancel(timer);
                                      if (sheetContext.mounted) {
                                        Navigator.of(sheetContext).pop();
                                      }
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
