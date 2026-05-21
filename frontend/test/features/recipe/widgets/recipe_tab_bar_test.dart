import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_tab_bar.dart';

class _TabHost extends StatefulWidget {
  const _TabHost();

  @override
  State<_TabHost> createState() => _TabHostState();
}

class _TabHostState extends State<_TabHost>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: RecipeTabBar(controller: _controller)),
    );
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('RecipeTabBar renders all four tab labels', (tester) async {
    await tester.pumpWidget(const _TabHost());

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
  });
}
