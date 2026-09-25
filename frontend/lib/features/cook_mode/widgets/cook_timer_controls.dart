import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
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
  final Future<void> Function(Duration duration, String? name) onStart;
  final Future<void> Function(CookTimer timer) onCancel;

  @override
  Widget build(BuildContext context) {
    final activeTimers = state.activeTimers;
    final activeCount = activeTimers.length;
    final summary = activeCount == 0
        ? 'Add a cooking timer'
        : '$activeCount active ${activeCount == 1 ? 'timer' : 'timers'}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 10, 2),
          child: Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              if (suggestedDuration != null)
                Expanded(
                  child: TextButton(
                    key: const Key('start-suggested-timer'),
                    onPressed: () =>
                        unawaited(onStart(suggestedDuration!, null)),
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(
                      'Start ${formatCookDuration(suggestedDuration!)} timer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              else
                Expanded(
                  child: Text(
                    summary,
                    key: const Key('cook-timer-summary'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              IconButton(
                key: const Key('manage-cook-timers'),
                tooltip: 'Manage cooking timers',
                onPressed: () => _showTimerSheet(context, activeTimers),
                icon: const Icon(Icons.more_time),
                color: AppColors.primary,
                visualDensity: VisualDensity.compact,
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
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _CookTimerSheet(
        activeTimers: activeTimers,
        now: state.now,
        onStart: onStart,
        onCancel: onCancel,
      ),
    );
  }
}

class _CookTimerSheet extends StatefulWidget {
  const _CookTimerSheet({
    required this.activeTimers,
    required this.now,
    required this.onStart,
    required this.onCancel,
  });

  final List<CookTimer> activeTimers;
  final DateTime now;
  final Future<void> Function(Duration duration, String? name) onStart;
  final Future<void> Function(CookTimer timer) onCancel;

  @override
  State<_CookTimerSheet> createState() => _CookTimerSheetState();
}

class _CookTimerSheetState extends State<_CookTimerSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _minutesController =
      TextEditingController(text: '10');
  int _minutes = 10;

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _updateMinutes(int value) {
    final nextMinutes = value.clamp(1, 180).toInt();
    setState(() {
      _minutes = nextMinutes;
      _minutesController.value = TextEditingValue(
        text: '$nextMinutes',
        selection: TextSelection.collapsed(
          offset: '$nextMinutes'.length,
        ),
      );
    });
  }

  void _limitName(String value) {
    if (value.length <= 40) return;
    final shortened = value.substring(0, 40);
    _nameController.value = TextEditingValue(
      text: shortened,
      selection: const TextSelection.collapsed(offset: 40),
    );
  }

  Future<void> _startTimer() async {
    final enteredMinutes = int.tryParse(_minutesController.text);
    final durationMinutes = (enteredMinutes ?? _minutes).clamp(1, 180).toInt();
    await widget.onStart(
      Duration(minutes: durationMinutes),
      _nameController.text,
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _cancelTimer(CookTimer timer) async {
    await widget.onCancel(timer);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final activeTimers = widget.activeTimers;
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.72,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                activeTimers.isEmpty ? 'Add a timer' : 'Add another timer',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 18),
              AppTextField.standard(
                key: const Key('manual-timer-name'),
                controller: _nameController,
                label: 'Timer name (optional)',
                hint: 'e.g. Sauce, rice, pasta',
                prefixIcon: Icons.timer_outlined,
                onChanged: _limitName,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      key: const Key('decrease-manual-timer'),
                      tooltip: 'Decrease timer by one minute',
                      onPressed: _minutes > 1
                          ? () => _updateMinutes(_minutes - 1)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Expanded(
                      child: TextField(
                        key: const Key('manual-timer-duration-input'),
                        controller: _minutesController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        style: AppTextStyles.heading2,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          suffixText: 'min',
                        ),
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed == null) return;
                          setState(() {
                            _minutes = parsed.clamp(1, 180).toInt();
                          });
                        },
                      ),
                    ),
                    IconButton.filledTonal(
                      key: const Key('increase-manual-timer'),
                      tooltip: 'Increase timer by one minute',
                      onPressed: _minutes < 180
                          ? () => _updateMinutes(_minutes + 1)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton.primary(
                key: const Key('start-manual-timer'),
                label: 'Start timer',
                leftIcon: Icons.timer_outlined,
                onPressed: _startTimer,
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
                            title: Text(timer.name ?? timer.label),
                            subtitle: Text(
                              '${formatCookDuration(timer.remainingAt(widget.now))} remaining - Step ${timer.stepNumber}',
                            ),
                            trailing: IconButton(
                              tooltip: 'Cancel ${timer.label}',
                              onPressed: () => _cancelTimer(timer),
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
  }
}
