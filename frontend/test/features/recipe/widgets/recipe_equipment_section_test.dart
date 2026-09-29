import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/equipment.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_equipment_section.dart';

Future<void> _pump(WidgetTester tester, List<Equipment> equipment) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: RecipeEquipmentSection(equipment: equipment)),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('lists each piece of equipment with its icon', (tester) async {
    await _pump(tester, const [
      Equipment(id: 1, value: 'OVEN', label: 'Oven'),
      Equipment(id: 2, value: 'STOVETOP', label: 'Stovetop'),
    ]);

    expect(find.text('Oven'), findsOneWidget);
    expect(find.text('Stovetop'), findsOneWidget);
    expect(find.byIcon(Icons.countertops_outlined), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department_outlined), findsOneWidget);
  });

  testWidgets('falls back to a default icon for unknown equipment',
      (tester) async {
    await _pump(tester, const [
      Equipment(id: 9, value: 'SOUS_VIDE', label: 'Sous Vide'),
    ]);

    expect(find.text('Sous Vide'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
  });

  testWidgets('renders nothing  for an empty list', (tester) async {
    await _pump(tester, const []);
    expect(find.byType(Text), findsNothing);
    expect(find.byType(Icon), findsNothing);
  });
}