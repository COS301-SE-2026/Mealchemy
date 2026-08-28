import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_toast.dart';

class ToastRequest {
  final int id;
  final ToastVariant variant;
  final ToastKind kind;
  final String message;
  final String? subtitle;
  final IconData? icon;
  final ImageProvider? thumbnail;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ToastRequest({
    required this.id,
    required this.variant,
    required this.kind,
    required this.message,
    this.subtitle,
    this.icon,
    this.thumbnail,
    this.actionLabel,
    this.onAction,
  });

  bool get hasAction => actionLabel != null && onAction != null;
}

class FeedbackNotifier extends StateNotifier<ToastRequest?> {
  FeedbackNotifier() : super(null);

  int _nextId = 0;

  void showShort(
    String message, {
    ToastKind kind = ToastKind.info,
    IconData? icon,
  }) {
    state = ToastRequest(
      id: _nextId++,
      variant: ToastVariant.short,
      kind: kind,
      message: message,
      icon: icon,
    );
  }

  void showLong(
    String message, {
    String? subtitle,
    ToastKind kind = ToastKind.info,
    IconData? icon,
    ImageProvider? thumbnail,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    state = ToastRequest(
      id: _nextId++,
      variant: ToastVariant.long,
      kind: kind,
      message: message,
      subtitle: subtitle,
      icon: icon,
      thumbnail: thumbnail,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void dismiss() => state = null;
}

final feedbackProvider =
    StateNotifierProvider<FeedbackNotifier, ToastRequest?>((ref) {
  return FeedbackNotifier();
});