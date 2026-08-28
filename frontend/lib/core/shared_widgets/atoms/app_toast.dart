import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

enum ToastVariant { short, long }

enum ToastKind { info, success, error }

///  The differen variants of the toast:
///  short single centred line with an optional leading icon
///  long leading icon or thumbnail, title + subtitle, optional trailing action

class AppToast extends StatelessWidget {
  final ToastVariant variant;
  final ToastKind kind;
  final String message;
  final String? subtitle;
  final IconData? icon;
  final ImageProvider? thumbnail;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppToast({
    super.key,
    required this.message,
    this.variant = ToastVariant.short,
    this.kind = ToastKind.info,
    this.subtitle,
    this.icon,
    this.thumbnail,
    this.actionLabel,
    this.onAction,
  });

  const AppToast.short({
    super.key,
    required this.message,
    this.kind = ToastKind.info,
    this.icon,
  })  : variant = ToastVariant.short,
        subtitle = null,
        thumbnail = null,
        actionLabel = null,
        onAction = null;

  const AppToast.long({
    super.key,
    required this.message,
    this.subtitle,
    this.kind = ToastKind.info,
    this.icon,
    this.thumbnail,
    this.actionLabel,
    this.onAction,
  }) : variant = ToastVariant.long;

  bool get _hasAction => actionLabel != null && onAction != null;

  bool get _isError => kind == ToastKind.error;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.textDark.withValues(alpha: 0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isError) Container(width: 4, color: AppColors.error),
                  Flexible(
                    child: variant == ToastVariant.short
                        ? _buildShort()
                        : _buildLong(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShort() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 18,
                color: _isError ? AppColors.error : AppColors.textDark),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.toast.copyWith(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLong() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _buildLeading(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTextStyles.toast.copyWith(color: AppColors.textDark),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.toastSubtitle.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_hasAction) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.toast.copyWith(color: AppColors.textDark),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeading() {
    if (thumbnail != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image(
          image: thumbnail!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: (_isError ? AppColors.error : AppColors.textDark)
            .withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon ?? Icons.notifications_none,
        size: 20,
        color: _isError ? AppColors.error : AppColors.textDark,
      ),
    );
  }
}
