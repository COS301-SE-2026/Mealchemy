import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_network_image.dart';

void main() {
  Widget host(String? photoUrl) {
    return MaterialApp(
      home: RecipeNetworkImage(
        photoUrl: photoUrl,
        placeholder: const SizedBox(key: Key('recipe-image-placeholder')),
      ),
    );
  }

  testWidgets('shows the placeholder when the photo url is missing',
      (tester) async {
    await tester.pumpWidget(host(null));

    expect(find.byKey(const Key('recipe-image-placeholder')), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('uses the cached image widget for a photo url', (tester) async {
    await tester.pumpWidget(host('https://example.test/meal.jpg'));

    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });
}
