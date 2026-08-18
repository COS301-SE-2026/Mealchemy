import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/models/selected_recipe_photo.dart';
import 'package:mealchemy/features/recipe/models/unit_of_measurement.dart';
import 'package:mealchemy/features/recipe/providers/recipe_photo_provider.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_photo_repository.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';
import 'package:mealchemy/features/recipe/screens/add_recipe_screen.dart';
import 'package:mealchemy/features/recipe/services/recipe_photo_picker.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/models/vault_folder_recipe.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';


class _RecordingRepo implements RecipeRepository {
  _RecordingRepo({this.events});

  final List<Recipe> savedRecipes = [];
  final List<int> savedFolderIds = [];
  final List<(int id, Recipe recipe)> updatedRecipes = [];
  final List<String>? events;

  @override
  Future<Recipe> addRecipe(Recipe recipe, int folderId) async {
    events?.add('create');
    savedRecipes.add(recipe);
    savedFolderIds.add(folderId);
    return Recipe(
      recipeId: 501,
      title: recipe.title,
      description: recipe.description,
      cuisineType: recipe.cuisineType,
      prepTimeMins: recipe.prepTimeMins,
      cookingTimeMins: recipe.cookingTimeMins,
      servingSize: recipe.servingSize,
      isCommunityPublished: recipe.isCommunityPublished,
    );
  }

  @override
  Future<Recipe> updateRecipe(int id, Recipe recipe) async {
    events?.add('update');
    updatedRecipes.add((id, recipe));
    return recipe.copyWith(recipeId: id);
  }

  @override
  Future<Recipe> updateRecipeFull(int id, Recipe recipe) async {
    updatedRecipes.add((id, recipe));
    return recipe.copyWith(recipeId: id);
  }

  @override
  Future<List<Recipe>> getRecipes() async => const [];

  @override
  Future<Recipe> getRecipeById(int id) async => throw UnimplementedError();

  @override
  Future<List<String>> getCuisineTypes() async =>
      const ['italian', 'asian', 'mexican'];

  @override
  Future<List<UnitOfMeasurement>> getUnits() async => const [
        UnitOfMeasurement(unitId: 1, name: 'g', system: 'METRIC'),
        UnitOfMeasurement(unitId: 2, name: 'tbsp', system: null),
      ];

  @override
  Future<void> addRecipeIngredient(int recipeId, RecipeIngredient i) async {}

  @override
  Future<void> addRecipeStep(int recipeId, RecipeStep s) async {}

  @override
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async =>
      const [];

  @override
  Future<List<RecipeStep>> getRecipeSteps(int recipeId) async => const [];

  @override
  Future<void> deleteRecipe(int recipeId) async {}
}

class _SlowCuisinesRepo extends _RecordingRepo {
  final _completer = Completer<List<String>>();
  @override
  Future<List<String>> getCuisineTypes() => _completer.future;
}

class _ThrowingCuisinesRepo extends _RecordingRepo {
  @override
  Future<List<String>> getCuisineTypes() async => throw Exception('boom');
}

class _FakePhotoPicker implements RecipePhotoPicker {
  _FakePhotoPicker({this.photo});

  final SelectedRecipePhoto? photo;
  RecipePhotoSource? selectedSource;

  @override
  Future<SelectedRecipePhoto?> pickPhoto(RecipePhotoSource source) async {
    selectedSource = source;
    return photo;
  }

  @override
  Future<SelectedRecipePhoto?> recoverLostPhoto() async => null;
}

class _RecordingPhotoRepository implements RecipePhotoRepository {
  _RecordingPhotoRepository({
    this.events,
    this.shouldFail = false,
  });

  final List<String>? events;
  final bool shouldFail;
  int? uploadedRecipeId;

  @override
  Future<String> uploadRecipePhoto({
    required int recipeId,
    required SelectedRecipePhoto photo,
  }) async {
    events?.add('upload');
    uploadedRecipeId = recipeId;
    if (shouldFail) throw Exception('upload failed');
    return 'https://storage.googleapis.com/recipes/$recipeId/photo.jpg';
  }
}

final _selectedPhoto = SelectedRecipePhoto.validate(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'meal.jpg',
  contentType: 'image/jpeg',
);


class _FakeVaultRepo implements VaultRepository {
  @override
  Future<List<Vault>> getMyVaults() async => [
        Vault(
          vaultId: 1,
          vaultType: VaultTypes.private,
          name: 'My Vault',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

  @override
  Future<List<VaultFolder>> getFolders(int vaultId) async => [
        VaultFolder(
          folderId: 10,
          vaultId: 1,
          folderName: 'My Recipes',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

  @override
  Future<VaultFolderRecipe> addRecipeToFolder(
      int folderId, int recipeId) async {
    return VaultFolderRecipe(
      id: 1,
      folderId: folderId,
      recipeId: recipeId,
      addedAt: DateTime(2026, 1, 1),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

const _editRecipe = Recipe(
  recipeId: 77,
  title: 'Existing Risotto',
  description: 'Creamy and rich',
  cuisineType: 'italian',
  prepTimeMins: 12,
  cookingTimeMins: 22,
  servingSize: 3,
  steps: [
    RecipeStep(stepNr: 1, content: 'Toast the rice'),
    RecipeStep(stepNr: 2, content: 'Add stock slowly'),
  ],
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host({
    required RecipeRepository recipeRepo,
    VaultRepository? vaultRepo,
    int? editRecipeId,
    Recipe? initialRecipe,
    List<Override> extraOverrides = const [],
    RecipePhotoPicker? photoPicker,
    RecipePhotoRepository? photoRepository,
  }) {
    final router = GoRouter(
      initialLocation: '/recipe/add',
      routes: [
        GoRoute(
          path: '/recipe/add',
          builder: (context, state) => AddRecipeScreen(
            editRecipeId: editRecipeId,
            initialRecipe: initialRecipe,
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(recipeRepo),
        recipePhotoPickerProvider.overrideWithValue(
          photoPicker ?? _FakePhotoPicker(),
        ),
        recipePhotoRepositoryProvider.overrideWithValue(
          photoRepository ?? _RecordingPhotoRepository(),
        ),
        vaultRepositoryProvider
            .overrideWithValue(vaultRepo ?? _FakeVaultRepo()),
        ...extraOverrides,
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pumpAddRecipe(
    WidgetTester tester, {
    required RecipeRepository recipeRepo,
    VaultRepository? vaultRepo,
    int? editRecipeId,
    Recipe? initialRecipe,
    List<Override> extraOverrides = const [],
    RecipePhotoPicker? photoPicker,
    RecipePhotoRepository? photoRepository,
  }) async {
    tester.view.physicalSize = const Size(414, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(host(
      
      recipeRepo: recipeRepo,
     
      vaultRepo: vaultRepo,
      photoPicker: photoPicker,
      photoRepository: photoRepository,
      editRecipeId: editRecipeId,
      initialRecipe: initialRecipe,
      extraOverrides: extraOverrides,
    ));
  }

  Future<void> tapCreateRecipe(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Cancel'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final cta = find.text('Create Recipe');
    await tester.ensureVisible(cta.last);
    await tester.pumpAndSettle();
    await tester.tap(cta.last);
    await tester.pumpAndSettle();
  }

  Future<void> tapSaveChanges(WidgetTester tester) async {
    final cta = find.text('Save Changes');
    await tester.ensureVisible(cta.last);
    await tester.pumpAndSettle();
    await tester.tap(cta.last);
    await tester.pumpAndSettle();
  }

  Future<void> selectCuisine(WidgetTester tester, String label) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> fillRequiredFields(WidgetTester tester) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'My New Recipe');
    await tester.enterText(fields.at(2), '10');
    await tester.enterText(fields.at(3), '25');
    await tester.enterText(fields.at(4), '6');
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Italian').last);
    await tester.pumpAndSettle();
  }

  testWidgets('shows a loading indicator while cuisines are loading',
      (tester) async {
    await pumpAddRecipe(tester, recipeRepo: _SlowCuisinesRepo());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error widget when cuisines fail to load',
      (tester) async {
    await pumpAddRecipe(tester, recipeRepo: _ThrowingCuisinesRepo());
    await tester.pumpAndSettle();
    expect(find.text('Unable to load form data.'), findsOneWidget);
  });

  testWidgets('renders the header, section titles and CTAs', (tester) async {
    await pumpAddRecipe(tester, recipeRepo: _RecordingRepo());
    await tester.pumpAndSettle();

    expect(find.text('Create Recipe'), findsWidgets);
    expect(find.text('Recipe Details'), findsOneWidget);
    expect(find.text('Recipe Photo'), findsOneWidget);
    expect(find.text('Time & Servings'), findsOneWidget);
    expect(find.text('Save To'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Preparation Steps'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Cancel'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('submit with missing required fields shows per-field errors',
      (tester) async {
    final repo = _RecordingRepo();
    await pumpAddRecipe(tester, recipeRepo: repo);
    await tester.pumpAndSettle();

    await tapCreateRecipe(tester);

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Title is required.'),
      -400,
      scrollable: scrollable,
    );
    expect(find.text('Title is required.'), findsOneWidget);
    expect(find.text('Cuisine is required.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Prep, cook, and servings are all required.'),
      400,
      scrollable: scrollable,
    );
    expect(find.text('Prep, cook, and servings are all required.'),
        findsOneWidget);
    expect(repo.savedRecipes, isEmpty);
  });

  testWidgets('a fully valid form saves the recipe with the entered values',
      (tester) async {
    final repo = _RecordingRepo();
    await pumpAddRecipe(tester, recipeRepo: repo);
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'My New Recipe');
    await tester.enterText(fields.at(2), '10');
    await tester.enterText(fields.at(3), '25');
    await tester.enterText(fields.at(4), '6');

    await selectCuisine(tester, 'Italian');

    await tapCreateRecipe(tester);

    expect(repo.savedRecipes, hasLength(1));
    final saved = repo.savedRecipes.first;
    expect(saved.title, 'My New Recipe');
    expect(saved.cuisineType, 'italian');
    expect(saved.prepTimeMins, 10);
    expect(saved.cookingTimeMins, 25);
    expect(saved.servingSize, 6);
    expect(saved.recipeId, 0);
    expect(saved.isCommunityPublished, isFalse);
    expect(repo.savedFolderIds, [10]);
  });

  testWidgets('empty description is sent as null, not an empty string',
      (tester) async {
    final repo = _RecordingRepo();
    await pumpAddRecipe(tester, recipeRepo: repo);
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Just a title');
    await tester.enterText(fields.at(2), '5');
    await tester.enterText(fields.at(3), '5');
    await tester.enterText(fields.at(4), '2');

    await selectCuisine(tester, 'Asian');

    await tapCreateRecipe(tester);

    expect(repo.savedRecipes.first.description, isNull);
  });

  testWidgets('edit mode prefills the form and shows edit labels',
      (tester) async {
    await pumpAddRecipe(
      tester,
      recipeRepo: _RecordingRepo(),
      editRecipeId: 77,
      initialRecipe: _editRecipe,
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Recipe'), findsWidgets);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Save To'), findsNothing);
    expect(find.text('Existing Risotto'), findsOneWidget);
    expect(find.text('Creamy and rich'), findsOneWidget);
    expect(find.text('Toast the rice'), findsOneWidget);
    expect(find.text('Add stock slowly'), findsOneWidget);
  });

  testWidgets('saving an edit calls updateRecipeFull with the recipe id',
      (tester) async {
    final repo = _RecordingRepo();
    await pumpAddRecipe(
      tester,
      recipeRepo: repo,
      editRecipeId: 77,
      initialRecipe: _editRecipe,
    );
    await tester.pumpAndSettle();

    await tapSaveChanges(tester);

    expect(repo.updatedRecipes, hasLength(1));
    expect(repo.updatedRecipes.first.$1, 77);
    expect(repo.updatedRecipes.first.$2.title, 'Existing Risotto');
    expect(repo.savedRecipes, isEmpty);
  });

  testWidgets('edit mode shows the error widget when the detail load fails',
      (tester) async {
    await pumpAddRecipe(
      tester,
      recipeRepo: _RecordingRepo(),
      editRecipeId: 99,
      extraOverrides: [
        recipeDetailProvider(99)
            .overrideWith((ref) async => throw Exception('detail boom')),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load form data.'), findsOneWidget);
  });

  testWidgets('selected photo is previewed and uploaded after recipe creation',
      (tester) async {
    final events = <String>[];
    final recipeRepo = _RecordingRepo(events: events);
    final photoRepo = _RecordingPhotoRepository(events: events);
    final picker = _FakePhotoPicker(photo: _selectedPhoto);
    await pumpAddRecipe(
      tester,
      recipeRepo: recipeRepo,
      photoPicker: picker,
      photoRepository: photoRepo,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('recipe-photo-gallery')));
    await tester.pumpAndSettle();
    expect(picker.selectedSource, RecipePhotoSource.gallery);
    expect(find.byKey(const Key('recipe-photo-preview')), findsOneWidget);

    await fillRequiredFields(tester);
    await tapCreateRecipe(tester);

    expect(events, ['create', 'upload', 'update']);
    expect(photoRepo.uploadedRecipeId, 501);
    expect(
      recipeRepo.updatedRecipes.single.$2.photoUrl,
      'https://storage.googleapis.com/recipes/501/photo.jpg',
    );
  });

  testWidgets('photo upload failure does not fail the saved recipe',
      (tester) async {
    final recipeRepo = _RecordingRepo();
    await pumpAddRecipe(
      tester,
      recipeRepo: recipeRepo,
      photoPicker: _FakePhotoPicker(photo: _selectedPhoto),
      photoRepository: _RecordingPhotoRepository(shouldFail: true),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('recipe-photo-camera')));
    await tester.pumpAndSettle();
    await fillRequiredFields(tester);

    await tapCreateRecipe(tester);

    expect(recipeRepo.savedRecipes, hasLength(1));
    expect(recipeRepo.updatedRecipes, isEmpty);
    expect(find.text('Recipe saved, but the photo did not upload.'),
        findsOneWidget);
  });
}
