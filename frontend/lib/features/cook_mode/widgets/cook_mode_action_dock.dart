import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/cook_narration_state.dart';

class CookModeActionDock extends StatelessWidget {
  const CookModeActionDock({
    super.key,
    required this.narration,
    required this.canGoBack,
    required this.isLastStep,
    required this.isVoiceModeEnabled,
    required this.isVoiceInitializing,
    required this.isVoiceUnavailable,
    required this.onBack,
    required this.onNarration,
    required this.onVoiceMode,
    required this.onNext,
  });

  final CookNarrationState narration;
  final bool canGoBack;
  final bool isLastStep;
  final bool isVoiceModeEnabled;
  final bool isVoiceInitializing;
  final bool isVoiceUnavailable;
  final VoidCallback onBack;
  final VoidCallback onNarration;
  final VoidCallback onVoiceMode;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final (narrationIcon, narrationLabel) = switch (narration.status) {
      CookNarrationStatus.preparing => (Icons.more_horiz, 'Preparing'),
      CookNarrationStatus.speaking => (Icons.pause, 'Pause'),
      CookNarrationStatus.paused => (Icons.play_arrow, 'Resume'),
      CookNarrationStatus.unavailable => (
          Icons.volume_off_outlined,
          'Unavailable'
        ),
      _ => (Icons.volume_up_outlined, 'Replay'),
    };

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DockAction(
                  key: const Key('cook-back-button'),
                  icon: Icons.arrow_back,
                  label: 'Back',
                  tooltip: 'Previous step',
                  onPressed: canGoBack ? onBack : null,
                ),
              ),
              Expanded(
                child: _DockAction(
                  icon: narrationIcon,
                  label: narrationLabel,
                  tooltip: narrationLabel,
                  onPressed: narration.isUnavailable ? null : onNarration,
                ),
              ),
              Expanded(
                child: _DockAction(
                  key: const Key('cook-voice-mode-button'),
                  icon: isVoiceUnavailable ? Icons.mic_off : Icons.mic,
                  label: isVoiceModeEnabled ? 'Voice on' : 'Speak',
                  tooltip: isVoiceModeEnabled
                      ? 'Turn off voice mode'
                      : 'Turn on voice mode',
                  onPressed: isVoiceInitializing ? null : onVoiceMode,
                  isSelected: isVoiceModeEnabled,
                  isLoading: isVoiceInitializing,
                ),
              ),
              Expanded(
                child: _DockAction(
                  key: const Key('cook-next-button'),
                  icon: isLastStep ? Icons.check : Icons.arrow_forward,
                  label: isLastStep ? 'Finish' : 'Next',
                  tooltip: isLastStep ? 'Finish cooking' : 'Next step',
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockAction extends StatelessWidget {
  const _DockAction({
    super.key,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
    this.isSelected = false,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final foreground = !enabled
        ? AppColors.textMuted
        : isSelected
            ? Colors.white
            : AppColors.primary;
    final background = !enabled
        ? AppColors.textMuted.withValues(alpha: 0.08)
        : isSelected
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.07);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Tooltip(
        message: tooltip,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: background,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: SizedBox.square(
                  dimension: 52,
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(18),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: foreground,
                          ),
                        )
                      : Icon(icon, color: foreground, size: 26),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: enabled
                    ? isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.onSurface
                    : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
