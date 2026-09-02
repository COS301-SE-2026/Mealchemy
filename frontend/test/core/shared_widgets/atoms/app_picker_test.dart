import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_picker.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const options = [
    AppPickerOption(value: 1, label: 'Apples', icon: Icons.apple),
    AppPickerOption(value: 2, label: 'Bananas', icon: Icons.cake),
  ];

  Widget host({
    int? initial,
    bool enabled = true,
    String? hint,
    void Function(int)? onPicked,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: _Controlled(
            initial: initial,
            enabled: enabled,
            hint: hint,
            options: options,
            onPicked: onPicked,
          ),
        ),
      ),
    );
  }

  testWidgets('shows the hint when no value is selected', (tester) async {
    await tester.pumpWidget(host(hint: 'Pick a fruit'));

    expect(find.text('Pick a fruit'), findsOneWidget);
    expect(find.text('Apples'), findsNothing); 
  });

  testWidgets('shows the selected option label on the trigger', (tester) async {
    await tester.pumpWidget(host(initial: 2));

    expect(find.text('Bananas'), findsOneWidget);
  });

  testWidgets('opening reveals the options', (tester) async {
    await tester.pumpWidget(host(hint: 'Pick'));

    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('Bananas'), findsOneWidget);
  });

  testWidgets('picking an option fires onChanged and closes the menu',
      (tester) async {
    int? picked;
    await tester.pumpWidget(host(hint: 'Pick', onPicked: (v) => picked = v));

    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apples'));
    await tester.pumpAndSettle();

    expect(picked, 1);
    expect(find.text('Bananas'), findsNothing);
    expect(find.text('Apples'), findsOneWidget);
  });

  testWidgets('a disabled picker does not open', (tester) async {
    await tester.pumpWidget(host(hint: 'Pick', enabled: false));

    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsNothing);
  });

  testWidgets('tapping outside dismisses the menu', (tester) async {
    await tester.pumpWidget(host(hint: 'Pick'));

    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();
    expect(find.text('Apples'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsNothing);
  });

  testWidgets('the selected option shows a check in the open menu',
      (tester) async {
    await tester.pumpWidget(host(initial: 1));
    await tester.tap(find.text('Apples').first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}

class _Controlled extends StatefulWidget {
  const _Controlled({
    required this.initial,
    required this.enabled,
    required this.hint,
    required this.options,
    required this.onPicked,
  });

  final int? initial;
  final bool enabled;
  final String? hint;
  final List<AppPickerOption<int>> options;
  final void Function(int)? onPicked;

  @override
  State<_Controlled> createState() => _ControlledState();
}

class _ControlledState extends State<_Controlled> {
  late int? _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return AppPicker<int>(
      value: _value,
      hint: widget.hint,
      enabled: widget.enabled,
      options: widget.options,
      onChanged: (v) {
        widget.onPicked?.call(v);
        setState(() => _value = v);
      },
    );
  }
}