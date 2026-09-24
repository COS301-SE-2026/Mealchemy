import 'package:flutter/material.dart';

import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class WeightSlider extends StatelessWidget {
  const WeightSlider({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final String subtitle;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: title, leadingIcon: icon),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              trackShape: const _GradientTrackShape(),
              inactiveTrackColor: AppColors.inputBorder,
              thumbColor: AppColors.accent,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: value.clamp(0, 1),
              min: 0,
              max: 1,
              padding: EdgeInsets.zero,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientTrackShape extends RoundedRectSliderTrackShape {
  const _GradientTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final height = sliderTheme.trackHeight ?? 6;
    final top = offset.dy + (parentBox.size.height - height) / 2;
    const inset = 10.0;
    return Rect.fromLTWH(
      offset.dx + inset,
      top,
      parentBox.size.width - inset * 2,
      height,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final radius = Radius.circular(rect.height / 2);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()..color = sliderTheme.inactiveTrackColor ?? AppColors.inputBorder,
    );

    if (thumbCenter.dx > rect.left) {
      final activeRect =
          Rect.fromLTRB(rect.left, rect.top, thumbCenter.dx, rect.bottom);
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(activeRect, radius),
        Paint()..shader = AppColors.brand.createShader(activeRect),
      );
    }
  }
}