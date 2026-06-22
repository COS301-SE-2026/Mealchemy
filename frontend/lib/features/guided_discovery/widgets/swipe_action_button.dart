import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';

//button used in swipe interactions
class SwipeActionButton extends StatelessWidget {
  const SwipeActionButton({
    super.key,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.size,
    required this.onTap,
    this.borderColor,
  });

  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final double size;
  final VoidCallback onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: CircleBorder(
        side: BorderSide(
          color: borderColor ?? Colors.transparent,
        ),
      ),
      //elevation adds shadow
      elevation: 8,
      shadowColor: AppColors.primary.withValues(alpha: 0.14),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: foregroundColor,
            size: size * 0.42,
          ),
        ),
      ),
    );
  }
}