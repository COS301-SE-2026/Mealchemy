import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_narration_state.dart';
import 'package:mealchemy/features/cook_mode/widgets/cook_mode_action_dock.dart';

Widget _host({
  CookNarrationState narration = const CookNarrationState(),
  bool voiceEnabled = false,
  VoidCallback? onVoice,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          const Spacer(),
          CookModeActionDock(
            narration: narration,
            canGoBack: true,
            isLastStep: false,
            isVoiceModeEnabled: voiceEnabled,
            isVoiceInitializing: false,
            isVoiceUnavailable: false,
            onBack: () {},
            onNarration: () {},
            onVoiceMode: onVoice ?? () {},
            onNext: () {},
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('shows four stable manual actions', (tester) async {
    await tester.pumpWidget(_host());

    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Replay'), findsOneWidget);
    expect(find.text('Speak'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('highlights the persistent voice-mode action', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(
      voiceEnabled: true,
      onVoice: () => taps++,
    ));

    expect(find.text('Voice on'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cook-voice-mode-button')));
    expect(taps, 1);
  });

  testWidgets('reflects active narration in the replay position',
      (tester) async {
    await tester.pumpWidget(_host(
      narration: const CookNarrationState(
        status: CookNarrationStatus.speaking,
      ),
    ));

    expect(find.text('Pause'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
  });
}
