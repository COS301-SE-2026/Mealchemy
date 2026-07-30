import 'package:flutter/material.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class HelpBodyText extends StatelessWidget {
  const HelpBodyText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textLight,
        height: 1.5,
      ),
    );
  }
}

class HelpIconRow extends StatelessWidget {
  const HelpIconRow({
    super.key,
    required this.icon,
    required this.value,
    this.label,
  });

  final IconData icon;
  final String value;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          if (label != null) ...[
            Text(
              label!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpIconBullet extends StatelessWidget {
  const HelpIconBullet({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //gradient icon marker with a soft shadow
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.brand,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.textDark, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textLight,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}