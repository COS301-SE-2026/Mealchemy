import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Shared scroll-to-first-error behaviour for any form.
mixin ScrollHelper<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // Scrolls the topmost errored field into view. Pass the field keys in the order thy appear
  void scrollToFirstError(List<(GlobalKey key, bool hasError)> fields) {
    final firstErrored = fields.where((f) => f.$2).map((f) => f.$1).firstOrNull;

    final ctx = firstErrored?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }
}