import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/sizzles/widgets/sizzle_video_player.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_network_image.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  late VideoPlayerPlatform originalPlatform;
  late _FakeVideoPlayerPlatform platform;

  setUp(() {
    originalPlatform = VideoPlayerPlatform.instance;
    platform = _FakeVideoPlayerPlatform();
    VideoPlayerPlatform.instance = platform;
  });

  tearDown(() async {
    VideoPlayerPlatform.instance = originalPlatform;
    await platform.close();
  });

  testWidgets('initializes active videos as looping and muted', (tester) async {
    await _pumpPlayer(tester, active: true, muted: true);

    expect(platform.dataSources.single.uri, 'https://cdn.test/video.mp4');
    expect(platform.loopingValues.last, isTrue);
    expect(platform.volumeValues.last, 0);
    expect(platform.calls, contains('play'));
    expect(find.byKey(const ValueKey('video-view-0')), findsOneWidget);
  });

  testWidgets('reacts to mute and active-page changes', (tester) async {
    await _pumpPlayer(tester, active: false, muted: true);
    platform.calls.clear();
    platform.volumeValues.clear();

    await _pumpPlayer(tester, active: true, muted: false);

    expect(platform.volumeValues.last, 1);
    expect(platform.calls, contains('play'));

    platform.calls.clear();
    await _pumpPlayer(tester, active: false, muted: false);

    expect(platform.calls, contains('pause'));
  });

  testWidgets('toggles playback when the video is tapped', (tester) async {
    await _pumpPlayer(tester, active: true, muted: true);
    platform.calls.clear();

    await tester.tap(find.byType(SizzleVideoPlayer));
    await tester.pump();

    expect(platform.calls, contains('pause'));
    expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);

    platform.calls.clear();
    await tester.tap(find.byType(SizzleVideoPlayer));
    await tester.pump();

    expect(platform.calls, contains('play'));
    expect(find.byIcon(Icons.play_circle_fill), findsNothing);
  });

  testWidgets('shows the recipe photo while video initialization is pending',
      (tester) async {
    platform.deferInitialization = true;

    await tester.pumpWidget(
      const MaterialApp(
        home: SizzleVideoPlayer(
          videoUrl: 'https://cdn.test/video.mp4',
          posterUrl: 'https://cdn.test/poster.jpg',
          active: true,
          muted: true,
        ),
      ),
    );
    await tester.pump();

    final poster = tester.widget<RecipeNetworkImage>(
      find.byKey(const ValueKey('sizzle-video-poster')),
    );
    expect(poster.photoUrl, 'https://cdn.test/poster.jpg');
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('pauses for app backgrounding and resumes when active',
      (tester) async {
    await _pumpPlayer(tester, active: true, muted: true);
    platform.calls.clear();

    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.paused,
    );
    await tester.pump();
    expect(platform.calls, contains('pause'));

    platform.calls.clear();
    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await tester.pump();
    expect(platform.calls, contains('play'));
  });

  testWidgets('shows a fallback when initialization fails', (tester) async {
    platform.forceInitializationError = true;

    await _pumpPlayer(tester, active: true, muted: true);

    expect(find.byIcon(Icons.videocam_off_outlined), findsOneWidget);
  });
}

Future<void> _pumpPlayer(
  WidgetTester tester, {
  required bool active,
  required bool muted,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SizzleVideoPlayer(
        videoUrl: 'https://cdn.test/video.mp4',
        active: active,
        muted: muted,
      ),
    ),
  );
  for (var index = 0; index < 6; index++) {
    await tester.pump();
  }
}

class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final List<String> calls = [];
  final List<DataSource> dataSources = [];
  final List<bool> loopingValues = [];
  final List<double> volumeValues = [];
  final Map<int, StreamController<VideoEvent>> _streams = {};
  bool forceInitializationError = false;
  bool deferInitialization = false;
  int _nextPlayerId = 0;

  @override
  Future<void> init() async {
    calls.add('init');
  }

  @override
  Future<int?> create(DataSource dataSource) => _create(dataSource);

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) {
    return _create(options.dataSource);
  }

  Future<int> _create(DataSource dataSource) async {
    calls.add('create');
    final playerId = _nextPlayerId++;
    final stream = StreamController<VideoEvent>();
    _streams[playerId] = stream;
    dataSources.add(dataSource);
    if (forceInitializationError) {
      stream.addError(
        PlatformException(
          code: 'video_initialization_failed',
          message: 'Video initialization failed',
        ),
      );
    } else if (!deferInitialization) {
      stream.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          size: const Size(720, 1280),
          duration: const Duration(seconds: 20),
        ),
      );
    }
    return playerId;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return _streams[playerId]!.stream;
  }

  @override
  Future<void> dispose(int playerId) async {
    calls.add('dispose');
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {
    calls.add('setLooping');
    loopingValues.add(looping);
  }

  @override
  Future<void> setVolume(int playerId, double volume) async {
    calls.add('setVolume');
    volumeValues.add(volume);
  }

  @override
  Future<void> play(int playerId) async {
    calls.add('play');
  }

  @override
  Future<void> pause(int playerId) async {
    calls.add('pause');
  }

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Widget buildView(int playerId) {
    return SizedBox(key: ValueKey('video-view-$playerId'));
  }

  Future<void> close() async {
    for (final stream in _streams.values) {
      await stream.close();
    }
  }
}
