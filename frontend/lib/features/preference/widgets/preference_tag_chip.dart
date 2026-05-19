import 'package:flutter/material.dart';

import '../../../core/shared_widgets/atoms/app_chip.dart';

class PreferenceTagChip extends StatelessWidget {
  const PreferenceTagChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onRemove,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: label,
      selected: selected,
      onTap: onTap,
      onRemove: onRemove,
    );
  }
}