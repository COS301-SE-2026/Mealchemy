import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class CookVoiceIndicator extends StatelessWidget {
  const CookVoiceIndicator({
    super.key,
    required this.isListening,
    required this.soundLevel,
    required this.message,
  });

  final bool isListening;
  final double soundLevel;
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (!isListening && message == null) {
      return const SizedBox.shrink();
    }

    return Semantics(
      liveRegion: true,
      label: isListening ? 'Listening for a cooking command' : message,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
        child: isListening
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SoundBars(level: soundLevel),
                  const SizedBox(height: 6),
                  Text(
                    'Listening...',
                    key: const Key('cook-voice-listening'),
                    style: AppTextStyles.bodyBold.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Say “next”, “back”, or “repeat”.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              )
            : Text(
                message!,
                key: const Key('cook-voice-message'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
      ),
    );
  }
}

class _SoundBars extends StatelessWidget {
  const _SoundBars({required this.level});

  final double level;

  @override
  Widget build(BuildContext context) {
    const pattern = [0.35, 0.62, 0.9, 0.5, 0.72, 1.0, 0.55, 0.8, 0.42];
    final effectiveLevel = level.clamp(0.16, 1.0).toDouble();

    return SizedBox(
      key: const Key('cook-voice-sound-bars'),
      height: 30,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: pattern
            .map(
              (scale) => AnimatedContainer(
                duration: const Duration(milliseconds: 90),
                width: 4,
                height: 5 + (25 * scale * effectiveLevel),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.4 + (effectiveLevel * 0.6),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
