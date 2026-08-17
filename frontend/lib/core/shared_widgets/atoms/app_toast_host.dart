import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_toast.dart';
import 'package:mealchemy/core/providers/feedback_provider.dart';

// Overlays the current toast above the whole app.
class AppToastHost extends ConsumerStatefulWidget {
  final Widget? child;
  const AppToastHost({super.key, required this.child});

  @override
  ConsumerState<AppToastHost> createState() => _AppToastHostState();
}

class _AppToastHostState extends ConsumerState<AppToastHost>
    with SingleTickerProviderStateMixin {
  static const _autoDismiss = Duration(seconds: 4);

  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  ToastRequest? _current;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slide = Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onRequest(ToastRequest? req) {
    _timer?.cancel();
    if (req == null) {
      _controller.reverse().whenComplete(() {
        if (mounted) setState(() => _current = null);
      });
      return;
    }
    setState(() => _current = req);
    _controller.forward(from: 0);
    if (!req.hasAction) {
      _timer = Timer(_autoDismiss, _hide);
    }
  }

  void _hide() {
    _timer?.cancel();
    _controller.reverse().whenComplete(() {
      if (mounted) setState(() => _current = null);
    });
    ref.read(feedbackProvider.notifier).dismiss();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ToastRequest?>(feedbackProvider, (_, next) => _onRequest(next));

    final req = _current;
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (req != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 96,
            child: SafeArea(
              top: false,
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Dismissible(
                    key: ValueKey(req.id),
                    direction: DismissDirection.down,
                    onDismissed: (_) => _hide(),
                    child: Align(
                      alignment: req.variant == ToastVariant.short
                          ? Alignment.center
                          : Alignment.bottomCenter,
                      child: AppToast(
                        variant: req.variant,
                        kind: req.kind,
                        message: req.message,
                        subtitle: req.subtitle,
                        icon: req.icon,
                        thumbnail: req.thumbnail,
                        actionLabel: req.actionLabel,
                        onAction: req.hasAction
                            ? () {
                                req.onAction!();
                                _hide();
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}