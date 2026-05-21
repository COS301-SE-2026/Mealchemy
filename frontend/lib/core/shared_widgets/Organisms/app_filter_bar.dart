import 'package:flutter/material.dart';

import '../atoms/app_chip.dart';

//label and count for filtering
class AppFilterOption {
  const AppFilterOption({
    required this.label,
    this.count,
  });

  final String label;
  final int? count;
}

//horizontal filter
class AppFilterBar extends StatelessWidget {
  const AppFilterBar({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AppFilterOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final selected = index == selectedIndex;
          final label = option.count == null
              ? option.label
              : '${option.label}  ${option.count}';

          return Padding(
            padding: EdgeInsets.only(
              right: index == options.length - 1 ? 0 : 8,
            ),
            child: AppChip(
              label: label,
              selected: selected,
              onTap: () => onSelected(index),
            ),
          );
        }),
      ),
    );
  }
}