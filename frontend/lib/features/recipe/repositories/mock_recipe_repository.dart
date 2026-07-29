import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';
import 'recipe_repository.dart';
import '../models/unit_of_measurement.dart';

class MockRecipeRepository implements RecipeRepository {
  static final List<Recipe> _recipes = [
    Recipe(
      recipeId: 1,
      title: 'Penne Alla Vodka',
      photoUrl:
          'https://plus.unsplash.com/premium_photo-1664478288635-b9703a502393?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0',
      description:
          'A classic Italian-American pasta with a rich, creamy tomato and vodka sauce finished with Parmesan and fresh herbs. Comforting and deeply flavourful.',
      cuisineType: 'italian',
      prepTimeMins: 5,
      cookingTimeMins: 25,
      servingSize: 8,
      ingredients: const [
        RecipeIngredient(
            ingredientId: 27,
            recipeId: 1,
            ingId: 1001,
            name: 'Oil, olive, salad or cooking',
            quantity: 30,
            unit: 'ml',
            sortOrder: 1),
        RecipeIngredient(
            ingredientId: 28,
            recipeId: 1,
            ingId: 1025,
            name: 'Onions, yellow, raw',
            quantity: 0.5,
            unit: null,
            sortOrder: 2),
        RecipeIngredient(
            ingredientId: 29,
            recipeId: 1,
            ingId: 1019,
            name: 'Garlic, raw',
            quantity: 3,
            unit: null,
            sortOrder: 3),
        RecipeIngredient(
            ingredientId: 30,
            recipeId: 1,
            ingId: 1005,
            name: 'Salt, table',
            quantity: 2.5,
            unit: 'g',
            sortOrder: 4),
        RecipeIngredient(
            ingredientId: 31,
            recipeId: 1,
            ingId: 1026,
            name: 'Spices, pepper, red or cayenne',
            quantity: 2.5,
            unit: 'g',
            sortOrder: 5),
        RecipeIngredient(
            ingredientId: 32,
            recipeId: 1,
            ingId: 1027,
            name: 'Tomato products, canned, paste, without salt added',
            quantity: 170,
            unit: 'g',
            sortOrder: 6),
        RecipeIngredient(
            ingredientId: 33,
            recipeId: 1,
            ingId: 1028,
            name: 'Alcoholic beverage, distilled, vodka, 80 proof',
            quantity: 60,
            unit: 'ml',
            sortOrder: 7),
        RecipeIngredient(
            ingredientId: 34,
            recipeId: 1,
            ingId: 1029,
            name: 'Tomatoes, canned, red, ripe, diced',
            quantity: 400,
            unit: 'g',
            sortOrder: 8),
        RecipeIngredient(
            ingredientId: 35,
            recipeId: 1,
            ingId: 1015,
            name: 'Pasta, cooked, enriched, without added salt',
            quantity: 450,
            unit: 'g',
            sortOrder: 9),
        RecipeIngredient(
            ingredientId: 36,
            recipeId: 1,
            ingId: 1030,
            name: 'Cream, fluid, heavy whipping',
            quantity: 120,
            unit: 'ml',
            sortOrder: 10),
        RecipeIngredient(
            ingredientId: 37,
            recipeId: 1,
            ingId: 1031,
            name: 'Parsley, fresh',
            quantity: null,
            unit: null,
            sortOrder: 11),
        RecipeIngredient(
            ingredientId: 38,
            recipeId: 1,
            ingId: 1018,
            name: 'Cheese, parmesan, hard',
            quantity: null,
            unit: null,
            sortOrder: 12),
      ],
      steps: const [
        RecipeStep(
            stepId: 1,
            recipeId: 1,
            stepNr: 1,
            content:
                'Heat the olive oil in a large deep skillet over medium heat. Add the chopped onion, sliced garlic, salt, and red pepper flakes. Sauté for 5 to 8 minutes, stirring occasionally, until the onion is soft and translucent.'),
        RecipeStep(
            stepId: 2,
            recipeId: 1,
            stepNr: 2,
            content:
                'Add the tomato paste and cook for 3 minutes, stirring frequently, until it darkens to a deep red. Stir in the vodka and cook for 1 minute to cook off the alcohol.'),
        RecipeStep(
            stepId: 3,
            recipeId: 1,
            stepNr: 3,
            content:
                'Add the crushed whole peeled tomatoes and stir to combine. Reduce heat to low and simmer for 10 minutes.'),
        RecipeStep(
            stepId: 4,
            recipeId: 1,
            stepNr: 4,
            content:
                'Remove the sauce from the heat and allow to cool slightly. Transfer to a blender and blend until completely smooth. Set aside.'),
        RecipeStep(
            stepId: 5,
            recipeId: 1,
            stepNr: 5,
            content:
                'Bring a large pot of well-salted water to a boil. Cook the penne until al dente according to package instructions. Before draining, reserve 240ml of pasta water. Drain the pasta.'),
        RecipeStep(
            stepId: 6,
            recipeId: 1,
            stepNr: 6,
            content:
                'Return the blended sauce to the skillet over low heat. Stir in the heavy cream and 120ml of the reserved pasta water. Add the drained pasta and toss well, adding more pasta water a little at a time if needed to achieve a glossy, silky coating.'),
        RecipeStep(
            stepId: 7,
            recipeId: 1,
            stepNr: 7,
            content:
                'Serve immediately, topped with chopped fresh parsley or basil and a generous grating of Parmesan cheese.'),
      ],
    ),

    Recipe(
      recipeId: 2,
      title: 'Lemon Herb Salmon with Roasted Vegetables',
      photoUrl:
          'https://plus.unsplash.com/premium_photo-1723478417559-2349252a3dda?q=80&w=1066&auto=format&fit=crop&ixlib=rb-4.1.0',
      description:
          'Tender oven-roasted salmon fillets on a bed of colourful roasted vegetables, finished with a garlic, lemon, and herb dressing. Light, healthy, and ready in 30 minutes.',
      cuisineType: 'mediterranean',
      prepTimeMins: 10,
      cookingTimeMins: 20,
      servingSize: 4,
      ingredients: const [
        RecipeIngredient(
            ingredientId: 39,
            recipeId: 2,
            ingId: 1032,
            name: 'Fish, salmon, Atlantic, farmed, raw',
            quantity: 600,
            unit: 'g',
            sortOrder: 1),
        RecipeIngredient(
            ingredientId: 40,
            recipeId: 2,
            ingId: 1033,
            name: 'Squash, summer, zucchini, includes skin, raw',
            quantity: 2,
            unit: null,
            sortOrder: 2),
        RecipeIngredient(
            ingredientId: 41,
            recipeId: 2,
            ingId: 1034,
            name: 'Peppers, sweet, red, raw',
            quantity: 1,
            unit: null,
            sortOrder: 3),
        RecipeIngredient(
            ingredientId: 42,
            recipeId: 2,
            ingId: 1035,
            name: 'Peppers, sweet, yellow, raw',
            quantity: 1,
            unit: null,
            sortOrder: 4),
        RecipeIngredient(
            ingredientId: 43,
            recipeId: 2,
            ingId: 1021,
            name: 'Tomatoes, grape, raw',
            quantity: 200,
            unit: 'g',
            sortOrder: 5),
        RecipeIngredient(
            ingredientId: 44,
            recipeId: 2,
            ingId: 1001,
            name: 'Oil, olive, salad or cooking',
            quantity: 60,
            unit: 'ml',
            sortOrder: 6),
        RecipeIngredient(
            ingredientId: 45,
            recipeId: 2,
            ingId: 1016,
            name: 'Lemon juice, raw',
            quantity: 30,
            unit: 'ml',
            sortOrder: 7),
        RecipeIngredient(
            ingredientId: 46,
            recipeId: 2,
            ingId: 1019,
            name: 'Garlic, raw',
            quantity: 4,
            unit: null,
            sortOrder: 8),
        RecipeIngredient(
            ingredientId: 47,
            recipeId: 2,
            ingId: 1036,
            name: 'Spices, oregano, dried',
            quantity: 5,
            unit: 'g',
            sortOrder: 9),
        RecipeIngredient(
            ingredientId: 48,
            recipeId: 2,
            ingId: 1037,
            name: 'Spices, thyme, dried',
            quantity: 5,
            unit: 'g',
            sortOrder: 10),
        RecipeIngredient(
            ingredientId: 49,
            recipeId: 2,
            ingId: 1005,
            name: 'Salt, table',
            quantity: 5,
            unit: 'g',
            sortOrder: 11),
        RecipeIngredient(
            ingredientId: 50,
            recipeId: 2,
            ingId: 1020,
            name: 'Spices, pepper, black',
            quantity: 2.5,
            unit: 'g',
            sortOrder: 12),
        RecipeIngredient(
            ingredientId: 51,
            recipeId: 2,
            ingId: 1031,
            name: 'Parsley, fresh',
            quantity: null,
            unit: null,
            sortOrder: 13),
      ],
      steps: const [
        RecipeStep(
            stepId: 8,
            recipeId: 2,
            stepNr: 1,
            content:
                'Preheat oven to 200°C. Line a large baking sheet with parchment paper.'),
        RecipeStep(
            stepId: 9,
            recipeId: 2,
            stepNr: 2,
            content:
                'Arrange the sliced zucchini, red and yellow bell peppers, and cherry tomatoes on the baking sheet. Drizzle with 30ml of the olive oil, season with salt and pepper, and toss to coat. Spread into an even single layer.'),
        RecipeStep(
            stepId: 10,
            recipeId: 2,
            stepNr: 3,
            content:
                'Place the salmon fillets on top of the vegetables. In a small bowl, mix the remaining 30ml olive oil with the lemon juice, minced garlic, dried oregano, and dried thyme. Spoon the herb mixture evenly over each fillet and season with the remaining salt and pepper.'),
        RecipeStep(
            stepId: 11,
            recipeId: 2,
            stepNr: 4,
            content:
                'Roast for 18 to 20 minutes until the salmon flakes easily with a fork and the vegetables are tender and lightly caramelised at the edges.'),
        RecipeStep(
            stepId: 12,
            recipeId: 2,
            stepNr: 5,
            content:
                'Remove from the oven, garnish with fresh parsley, and serve immediately directly from the pan.'),
      ],
    ),

    Recipe(
      recipeId: 3,
      title: 'Black Bean and Corn Burrito Bowls',
      photoUrl:
          'https://plus.unsplash.com/premium_photo-1667993847770-822fe09f35e4?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0',
      description:
          'A hearty and wholesome vegetarian meal prep bowl with spiced black beans and corn over brown rice, topped with avocado, fresh coriander, and sour cream.',
      cuisineType: 'mexican',
      prepTimeMins: 10,
      cookingTimeMins: 15,
      servingSize: 4,
      ingredients: const [
        RecipeIngredient(
            ingredientId: 52,
            recipeId: 3,
            ingId: 1038,
            name: 'Beans, black, mature seeds, cooked, boiled, without salt',
            quantity: 400,
            unit: 'g',
            sortOrder: 1),
        RecipeIngredient(
            ingredientId: 53,
            recipeId: 3,
            ingId: 1039,
            name: 'Corn, sweet, yellow, raw',
            quantity: 300,
            unit: 'g',
            sortOrder: 2),
        RecipeIngredient(
            ingredientId: 54,
            recipeId: 3,
            ingId: 1040,
            name: 'Rice, brown, long-grain, cooked',
            quantity: 400,
            unit: 'g',
            sortOrder: 3),
        RecipeIngredient(
            ingredientId: 55,
            recipeId: 3,
            ingId: 1034,
            name: 'Peppers, sweet, red, raw',
            quantity: 1,
            unit: null,
            sortOrder: 4),
        RecipeIngredient(
            ingredientId: 56,
            recipeId: 3,
            ingId: 1025,
            name: 'Onions, red, raw',
            quantity: 1,
            unit: null,
            sortOrder: 5),
        RecipeIngredient(
            ingredientId: 57,
            recipeId: 3,
            ingId: 1001,
            name: 'Oil, olive, salad or cooking',
            quantity: 30,
            unit: 'ml',
            sortOrder: 6),
        RecipeIngredient(
            ingredientId: 58,
            recipeId: 3,
            ingId: 1042,
            name: 'Spices, cumin, ground',
            quantity: 10,
            unit: 'g',
            sortOrder: 7),
        RecipeIngredient(
            ingredientId: 59,
            recipeId: 3,
            ingId: 1041,
            name: 'Spices, paprika',
            quantity: 5,
            unit: 'g',
            sortOrder: 8),
        RecipeIngredient(
            ingredientId: 60,
            recipeId: 3,
            ingId: 1043,
            name: 'Spices, garlic powder',
            quantity: 5,
            unit: 'g',
            sortOrder: 9),
        RecipeIngredient(
            ingredientId: 61,
            recipeId: 3,
            ingId: 1005,
            name: 'Salt, table',
            quantity: 5,
            unit: 'g',
            sortOrder: 10),
        RecipeIngredient(
            ingredientId: 62,
            recipeId: 3,
            ingId: 1044,
            name: 'Lime juice, raw',
            quantity: 30,
            unit: 'ml',
            sortOrder: 11),
        RecipeIngredient(
            ingredientId: 63,
            recipeId: 3,
            ingId: 1045,
            name: 'Avocados, raw, all commercial varieties',
            quantity: 1,
            unit: null,
            sortOrder: 12),
        RecipeIngredient(
            ingredientId: 64,
            recipeId: 3,
            ingId: 1046,
            name: 'Coriander (cilantro) leaves, raw',
            quantity: null,
            unit: null,
            sortOrder: 13),
        RecipeIngredient(
            ingredientId: 65,
            recipeId: 3,
            ingId: 1047,
            name: 'Cream, sour, reduced fat, cultured',
            quantity: null,
            unit: null,
            sortOrder: 14),
      ],
      steps: const [
        RecipeStep(
            stepId: 13,
            recipeId: 3,
            stepNr: 1,
            content:
                'Heat the olive oil in a large skillet over medium heat. Add the diced red onion and red bell pepper and cook for 5 minutes, stirring occasionally, until softened.'),
        RecipeStep(
            stepId: 14,
            recipeId: 3,
            stepNr: 2,
            content:
                'Add the drained black beans and thawed corn to the skillet. Season with ground cumin, smoked paprika, garlic powder, and sea salt. Stir to combine and cook for 5 minutes until everything is heated through.'),
        RecipeStep(
            stepId: 15,
            recipeId: 3,
            stepNr: 3,
            content:
                'Squeeze the fresh lime juice over the mixture, stir well, and remove from heat.'),
        RecipeStep(
            stepId: 16,
            recipeId: 3,
            stepNr: 4,
            content:
                'Divide the cooked brown rice evenly between 4 serving bowls. Spoon the black bean and corn mixture generously over the rice.'),
        RecipeStep(
            stepId: 17,
            recipeId: 3,
            stepNr: 5,
            content:
                'Top each bowl with sliced avocado and fresh coriander leaves. Add a dollop of sour cream and serve immediately.'),
      ],
    ),
  ];

  @override
  Future<List<Recipe>> getRecipes() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _recipes
        .map((r) => Recipe(
              recipeId: r.recipeId,
              title: r.title,
              description: r.description,
              cuisineType: r.cuisineType,
              prepTimeMins: r.prepTimeMins,
              cookingTimeMins: r.cookingTimeMins,
              servingSize: r.servingSize,
              photoUrl: r.photoUrl,
            ))
        .toList();
  }

  @override
  Future<Recipe> getRecipeById(int id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _recipes.firstWhere((r) => r.recipeId == id);
    } catch (_) {
      throw StateError('Recipe $id not found in mock data');
    }
  }

  @override
  Future<Recipe> addRecipe(Recipe recipe, int folderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Recipe(
      recipeId: 900 + _recipes.length,
      ownerId: 1,
      title: recipe.title,
      description: recipe.description,
      cuisineType: recipe.cuisineType,
      prepTimeMins: recipe.prepTimeMins,
      cookingTimeMins: recipe.cookingTimeMins,
      servingSize: recipe.servingSize,
      photoUrl: recipe.photoUrl,
      isCommunityPublished: recipe.isCommunityPublished,
    );
  }

  @override
  Future<Recipe> updateRecipe(int id, Recipe recipe) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Recipe(
      recipeId: id,
      ownerId: recipe.ownerId ?? 1,
      title: recipe.title,
      description: recipe.description,
      cuisineType: recipe.cuisineType,
      prepTimeMins: recipe.prepTimeMins,
      cookingTimeMins: recipe.cookingTimeMins,
      servingSize: recipe.servingSize,
      photoUrl: recipe.photoUrl,
      isCommunityPublished: recipe.isCommunityPublished,
    );
  }

  @override
  Future<List<String>> getCuisineTypes() async {
    return const [
      'african',
      'american',
      'asian',
      'caribbean',
      'chinese',
      'french',
      'greek',
      'indian',
      'italian',
      'japanese',
      'mediterranean',
      'mexican',
      'middle_eastern',
      'southeast_asian',
      'south_african',
      'thai',
      'other',
    ];
  }

  @override
  Future<void> addRecipeStep(int recipeId, RecipeStep step) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> addRecipeIngredient(
      int recipeId, RecipeIngredient ingredient) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async {
    final recipe = await getRecipeById(recipeId);
    return recipe.ingredients ?? [];
  }

  @override
  Future<List<RecipeStep>> getRecipeSteps(int recipeId) async {
    final recipe = await getRecipeById(recipeId);
    return recipe.steps ?? [];
  }

  @override
  Future<List<UnitOfMeasurement>> getUnits() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      UnitOfMeasurement(unitId: 1, name: 'grams', system: 'METRIC'),
      UnitOfMeasurement(unitId: 2, name: 'ml', system: 'METRIC'),
      UnitOfMeasurement(unitId: 3, name: 'cups', system: 'IMPERIAL'),
      UnitOfMeasurement(unitId: 4, name: 'tbsp', system: 'IMPERIAL'),
      UnitOfMeasurement(unitId: 5, name: 'tsp', system: 'IMPERIAL'),
    ];
  }
}