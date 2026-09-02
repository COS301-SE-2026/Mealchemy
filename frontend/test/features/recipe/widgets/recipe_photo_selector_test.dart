import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/selected_recipe_photo.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_photo_selector.dart';

//tests the photo controls embedded in the add recipe form
void main() {
  final photo = SelectedRecipePhoto.validate(
    bytes: Uint8List.fromList(base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    )),
    fileName: 'meal.png',
    contentType: 'image/png',
  );

  Widget host({
    SelectedRecipePhoto? selectedPhoto,
    String? existingPhotoUrl,
    VoidCallback? onGalleryTap,
    VoidCallback? onCameraTap,
    VoidCallback? onRemoveTap,
    bool disabled = false,
    bool uploading = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: RecipePhotoSelector(
          photo: selectedPhoto,
          existingPhotoUrl: existingPhotoUrl,
          onGalleryTap: onGalleryTap ?? () {},
          onCameraTap: onCameraTap ?? () {},
          onRemoveTap: onRemoveTap ?? () {},
          disabled: disabled,
          uploading: uploading,
        ),
      ),
    );
  }

  testWidgets('shows the placeholder and photo source buttons', (tester) async {
    await tester.pumpWidget(host());

    expect(find.byKey(const Key('recipe-photo-placeholder')), findsOneWidget);
    expect(find.byKey(const Key('recipe-photo-gallery')), findsOneWidget);
    expect(find.byKey(const Key('recipe-photo-camera')), findsOneWidget);
    expect(find.byKey(const Key('recipe-photo-remove')), findsNothing);
  });

  testWidgets('shows a selected photo and calls remove', (tester) async {
    var removed = false;
    await tester.pumpWidget(host(
      selectedPhoto: photo,
      onRemoveTap: () => removed = true,
    ));

    expect(find.byKey(const Key('recipe-photo-preview')), findsOneWidget);
    await tester.tap(find.byKey(const Key('recipe-photo-remove')));
    expect(removed, isTrue);
  });

  testWidgets('shows an existing network photo and calls remove',
      (tester) async {
    var removed = false;
    await tester.pumpWidget(host(
      existingPhotoUrl: 'https://example.test/meal.jpg',
      onRemoveTap: () => removed = true,
    ));

    expect(find.byKey(const Key('recipe-photo-preview')), findsOneWidget);
    await tester.tap(find.byKey(const Key('recipe-photo-remove')));
    expect(removed, isTrue);
  });

  testWidgets('calls gallery and camera actions', (tester) async {
    var galleryTapped = false;
    var cameraTapped = false;
    await tester.pumpWidget(host(
      onGalleryTap: () => galleryTapped = true,
      onCameraTap: () => cameraTapped = true,
    ));

    await tester.tap(find.byKey(const Key('recipe-photo-gallery')));
    await tester.tap(find.byKey(const Key('recipe-photo-camera')));
    expect(galleryTapped, isTrue);
    expect(cameraTapped, isTrue);
  });

  testWidgets('disables all actions while saving', (tester) async {
    await tester.pumpWidget(host(selectedPhoto: photo, disabled: true));

    final gallery = tester.widget<OutlinedButton>(
      find.byKey(const Key('recipe-photo-gallery')),
    );
    final camera = tester.widget<OutlinedButton>(
      find.byKey(const Key('recipe-photo-camera')),
    );
    final remove = tester.widget<IconButton>(
      find.byKey(const Key('recipe-photo-remove')),
    );

    expect(gallery.onPressed, isNull);
    expect(camera.onPressed, isNull);
    expect(remove.onPressed, isNull);
  });

  testWidgets('shows progress and disables actions while uploading',
      (tester) async {
    await tester.pumpWidget(host(selectedPhoto: photo, uploading: true));

    expect(find.byKey(const Key('recipe-photo-uploading')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final gallery = tester.widget<OutlinedButton>(
      find.byKey(const Key('recipe-photo-gallery')),
    );
    final camera = tester.widget<OutlinedButton>(
      find.byKey(const Key('recipe-photo-camera')),
    );
    final remove = tester.widget<IconButton>(
      find.byKey(const Key('recipe-photo-remove')),
    );

    expect(gallery.onPressed, isNull);
    expect(camera.onPressed, isNull);
    expect(remove.onPressed, isNull);
  });
}
