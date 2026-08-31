import 'package:flutter/material.dart';

import '../../theme/app_colours.dart';
import '../../theme/app_typography.dart';
import 'app_chip.dart';

class MultiSelectOption {
  const MultiSelectOption({required this.value, required this.label});

  final String value;
  final String label;
}

enum MultiSelectSurface { muted, white }

// A multi-select selected values show as white removable chips

class AppMultiSelect extends StatefulWidget {
  const AppMultiSelect({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onToggle,
    this.addLabel = 'Add',
    this.emptyHint,
    this.surface = MultiSelectSurface.muted,
  });

  final List<MultiSelectOption> options;
  final List<String> selectedValues;
  final ValueChanged<String> onToggle;
  final String addLabel;
  final String? emptyHint;
  final MultiSelectSurface surface;

  @override
  State<AppMultiSelect> createState() => _AppMultiSelectState();
}

class _AppMultiSelectState extends State<AppMultiSelect> {
  final _link = LayerLink();
  final _controller = OverlayPortalController();

  bool get _open => _controller.isShowing;

  List<MultiSelectOption> get _selected => widget.options
      .where((o) => widget.selectedValues.contains(o.value))
      .toList();

  List<MultiSelectOption> get _available => widget.options
      .where((o) => !widget.selectedValues.contains(o.value))
      .toList();

  void _toggleMenu() {
    _controller.toggle();
    setState(() {});
  }

  void _pick(String value) {
    widget.onToggle(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in selected)
              AppChip(
                label: option.label,
                variant: AppChipVariant.white,
                onRemove: () => widget.onToggle(option.value),
              ),
            if (_available.isNotEmpty) _addTrigger(),
          ],
        ),
        if (selected.isEmpty && widget.emptyHint != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.emptyHint!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }

  Widget _addTrigger() {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    const margin = 12.0;

    final box = context.findRenderObject() as RenderBox?;
    final triggerWidth = box?.size.width ?? 0;
    final triggerLeft =
        box != null ? box.localToGlobal(Offset.zero).dx : margin;
    final triggerRight = triggerLeft + triggerWidth;

    final wide = triggerWidth >= screenWidth / 2;
    final desired = wide ? triggerWidth : triggerWidth * 2;
    final maxOnScreen = screenWidth - (margin * 2);
    final menuWidth = desired.clamp(0.0, maxOnScreen).toDouble();

    final alignRight = triggerRight > screenWidth / 2;
    final Alignment targetAnchor =
        alignRight ? Alignment.bottomRight : Alignment.bottomLeft;
    final Alignment followerAnchor =
        alignRight ? Alignment.topRight : Alignment.topLeft;

    double dx = 0;
    if (alignRight) {
      final menuLeft = triggerRight - menuWidth;
      if (menuLeft < margin) dx = margin - menuLeft;
    } else {
      final menuRight = triggerLeft + menuWidth;
      if (menuRight > screenWidth - margin) {
        dx = (screenWidth - margin) - menuRight;
      }
    }

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
              targetAnchor: targetAnchor,
              followerAnchor: followerAnchor,
              offset: Offset(dx, 6),
              child: _MultiSelectMenu(
                options: _available,
                width: menuWidth,
                fill: widget.surface == MultiSelectSurface.white
                    ? AppColors.surfaceWhite
                    : AppColors.surfaceLight,
                onPick: _pick,
              ),
            ),
          ],
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: InkWell(
          onTap: _toggleMenu,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: widget.surface == MultiSelectSurface.white
                  ? AppColors.surfaceWhite
                  : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _open ? Icons.remove : Icons.add,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.addLabel,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
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

class _MultiSelectMenu extends StatelessWidget {
  const _MultiSelectMenu({
    required this.options,
    required this.onPick,
    required this.fill,
    required this.width,
  });

  final List<MultiSelectOption> options;
  final ValueChanged<String> onPick;
  final Color fill;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: width,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
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
                    InkWell(
                      onTap: () => onPick(options[i].value),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.add,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                options[i].label,
                                style: AppTextStyles.body
                                    .copyWith(color: AppColors.textLight),
                              ),
                            ),
                          ],
                        ),
                      ),
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