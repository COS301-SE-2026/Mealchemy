import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/widgets/cook_voice_indicator.dart';

Widget _host({
  required bool isListening,
  double soundLevel = 0,
  String? message,
}) {
  return MaterialApp(
    home: Scaffold(
      body: CookVoiceIndicator(
        isListening: isListening,
        soundLevel: soundLevel,
        message: message,
      ),
    ),
  );
}

void main() {
  testWidgets('stays hidden in clean manual mode', (tester) async {
    await tester.pumpWidget(_host(isListening: false));

    expect(find.byKey(const Key('cook-voice-sound-bars')), findsNothing);
    expect(find.text('Listening...'), findsNothing);
  });

  testWidgets('shows sound bars only while listening', (tester) async {
    await tester.pumpWidget(_host(isListening: true, soundLevel: 0.8));

    expect(find.byKey(const Key('cook-voice-sound-bars')), findsOneWidget);
    expect(find.text('Listening...'), findsOneWidget);
    expect(find.text('Say “next”, “back”, or “repeat”.'), findsOneWidget);
  });

  testWidgets('shows compact voice feedback without sound bars',
      (tester) async {
    await tester.pumpWidget(_host(
      isListening: false,
      message: 'Already at the first step.',
    ));

    expect(find.text('Already at the first step.'), findsOneWidget);
    expect(find.byKey(const Key('cook-voice-sound-bars')), findsNothing);
  });
}
