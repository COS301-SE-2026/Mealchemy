import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

enum PickerIconTone { primary, accent }

enum PickerSurface { muted, white }

class AppPickerOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppPickerOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

class AppPicker<T> extends StatefulWidget {
  const AppPicker({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.hint,
    this.iconTone = PickerIconTone.primary,
    this.surface = PickerSurface.muted,
    this.enabled = true,
  });

  final List<AppPickerOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String? hint;
  final PickerIconTone iconTone;
  final PickerSurface surface;
  final bool enabled;

  @override
  State<AppPicker<T>> createState() => _AppPickerState<T>();
}

class _AppPickerState<T> extends State<AppPicker<T>> {
  final _link = LayerLink();
  final _controller = OverlayPortalController();

  Color get _iconColor => widget.iconTone == PickerIconTone.accent
      ? AppColors.accent
      : AppColors.primary;

  Color get _triggerFill => widget.surface == PickerSurface.white
      ? AppColors.surfaceWhite
      : AppColors.surfaceMuted;

  Color get _menuFill => widget.surface == PickerSurface.white
      ? AppColors.surfaceWhite
      : AppColors.surfaceLight;

  AppPickerOption<T>? get _selected {
    for (final o in widget.options) {
      if (o.value == widget.value) return o;
    }
    return null;
  }

  bool get _open => _controller.isShowing;

  void _toggle() {
    if (!widget.enabled) return;
    _controller.toggle();
    setState(() {});
  }

  void _pick(T value) {
    widget.onChanged(value);
    _controller.hide();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _controller.hide();
                  setState(() {});
                },
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              child: _PickerMenu<T>(
                width: _triggerWidth(),
                options: widget.options,
                selectedValue: widget.value,
                iconColor: _iconColor,
                fill: _menuFill,
                onPick: _pick,
              ),
            ),
          ],
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: _trigger(),
      ),
    );
  }

  double _triggerWidth() {
    final box = context.findRenderObject() as RenderBox?;
    return box?.size.width ?? 0;
  }

  Widget _trigger() {
    final selected = _selected;
    final hasValue = selected != null;
    final label = selected?.label ?? widget.hint ?? 'Select';

    final radius = _open
        ? const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          )
        : BorderRadius.circular(14);

    return InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _triggerFill,
          borderRadius: radius,
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            if (selected?.icon != null) ...[
              Icon(selected!.icon, size: 18, color: _iconColor),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: hasValue ? AppColors.textLight : AppColors.textMuted,
                ),
              ),
            ),
            AnimatedRotation(
              turns: _open ? 0.5 : 0,
              duration: const Duration(milliseconds: 150),
              child: Icon(Icons.keyboard_arrow_down,
                  size: 20,
                  color: widget.enabled
                      ? AppColors.textMuted
                      : AppColors.inputBorder),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_controller.isShowing) _controller.hide();
    super.dispose();
  }
}

class _PickerMenu<T> extends StatelessWidget {
  const _PickerMenu({
    required this.width,
    required this.options,
    required this.selectedValue,
    required this.iconColor,
    required this.fill,
    required this.onPick,
  });

  final double width;
  final List<AppPickerOption<T>> options;
  final T? selectedValue;
  final Color iconColor;
  final Color fill;
  final ValueChanged<T> onPick;

  static const _radius = BorderRadius.only(
    bottomLeft: Radius.circular(14),
    bottomRight: Radius.circular(14),
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: _radius,
            border: Border(
              left:
                  BorderSide(color: AppColors.primary.withValues(alpha: 0.10)),
              right:
                  BorderSide(color: AppColors.primary.withValues(alpha: 0.10)),
              bottom:
                  BorderSide(color: AppColors.primary.withValues(alpha: 0.10)),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: _radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.primary.withValues(alpha: 0.08),
                        ),
                      _PickerRow<T>(
                        option: options[i],
                        selected: options[i].value == selectedValue,
                        iconColor: iconColor,
                        onTap: () => onPick(options[i].value),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerRow<T> extends StatelessWidget {
  const _PickerRow({
    required this.option,
    required this.selected,
    required this.iconColor,
    required this.onTap,
  });

  final AppPickerOption<T> option;
  final bool selected;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.primary.withValues(alpha: 0.05) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (option.icon != null) ...[
              Icon(option.icon, size: 20, color: iconColor),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                option.label,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(color: AppColors.textLight),
              ),
            ),
            if (selected) Icon(Icons.check, size: 18, color: iconColor),
          ],
        ),
      ),
    );
  }
}