import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../recipe/widgets/recipe_network_image.dart';

class SizzleVideoPlayer extends StatefulWidget {
  const SizzleVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.active,
    required this.muted,
    this.posterUrl,
  });

  final String videoUrl;
  final bool active;
  final bool muted;
  final String? posterUrl;

  @override
  State<SizzleVideoPlayer> createState() => _SizzleVideoPlayerState();
}

class _SizzleVideoPlayerState extends State<SizzleVideoPlayer>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted || !identical(_controller, controller)) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(true);
      await controller.setVolume(widget.muted ? 0 : 1);
      if (widget.active) await controller.play();
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted && identical(_controller, controller)) {
        setState(() => _failed = true);
      }
    }
  }

  @override
  void didUpdateWidget(covariant SizzleVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.dispose();
      _initialized = false;
      _failed = false;
      _initialize();
      return;
    }
    if (!_initialized) return;
    _controller.setVolume(widget.muted ? 0 : 1);
    if (widget.active) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialized) return;
    if (state == AppLifecycleState.resumed && widget.active) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  void _togglePlayback() {
    if (!_initialized) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return _SizzlePoster(
        photoUrl: widget.posterUrl,
        child: const Icon(
          Icons.videocam_off_outlined,
          color: Colors.white70,
        ),
      );
    }
    if (!_initialized) {
      return _SizzlePoster(
        photoUrl: widget.posterUrl,
        child: const CircularProgressIndicator(),
      );
    }

    final size = _controller.value.size;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlayback,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: VideoPlayer(_controller),
            ),
          ),
          if (!_controller.value.isPlaying)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 64,
              ),
            ),
        ],
      ),
    );
  }
}

class _SizzlePoster extends StatelessWidget {
  const _SizzlePoster({
    required this.photoUrl,
    required this.child,
  });

  final String? photoUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RecipeNetworkImage(
            key: const ValueKey('sizzle-video-poster'),
            photoUrl: photoUrl,
            placeholder: const SizedBox.shrink(),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}
