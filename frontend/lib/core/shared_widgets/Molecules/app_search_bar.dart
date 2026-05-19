import 'package:flutter/material.dart';

import '../atoms/app_text_field.dart';

//search input
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hint,
      prefixIcon: Icons.search,
      suffixIcon: onClear == null
          ? null
          : IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              tooltip: 'Clear search',
            ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}