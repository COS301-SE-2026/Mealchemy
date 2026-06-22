import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';
import 'recipe_repository.dart';

//mock data,

//mock saffron recipe from the wireframe
//to add photo
class MockRecipeRepository implements RecipeRepository {
  static final List<Recipe> _recipes = [
    Recipe(
      recipeId: 1,
      title: 'Saffron-Infused Risotto',
      description:
          'A rich and creamy Italian classic finished with saffron threads and parmesan.',
      cuisineType: 'italian',
      prepTimeMins: 15,
      cookingTimeMins: 30,
      servingSize: 4,
      ingredients: const [
        RecipeIngredient(
            ingredientId: 101,
            recipeId: 1,
            nameRaw: 'Arborio rice',
            quantity: 320,
            unit: 'g',
            sortOrder: 1),
        RecipeIngredient(
            ingredientId: 102,
            recipeId: 1,
            nameRaw: 'Saffron threads',
            quantity: 1,
            unit: 'pinch',
            sortOrder: 2),
        RecipeIngredient(
            ingredientId: 103,
            recipeId: 1,
            nameRaw: 'Garlic cloves',
            quantity: 3,
            unit: null,
            sortOrder: 3),
        RecipeIngredient(
            ingredientId: 104,
            recipeId: 1,
            nameRaw: 'Parmesan, grated',
            quantity: 80,
            unit: 'g',
            sortOrder: 4),
        RecipeIngredient(
            ingredientId: 105,
            recipeId: 1,
            nameRaw: 'Vegetable stock',
            quantity: 1,
            unit: 'L',
            sortOrder: 5),
      ],
      steps: const [
        RecipeStep(
            stepId: 201,
            recipeId: 1,
            stepNr: 1,
            content:
                'Warm the stock in a separate pot and steep the saffron threads in it until the colour bleeds out.'),
        RecipeStep(
            stepId: 202,
            recipeId: 1,
            stepNr: 2,
            content:
                'Toast the arborio rice with garlic in olive oil for two minutes, then add stock one ladle at a time, stirring until absorbed.'),
        RecipeStep(
            stepId: 203,
            recipeId: 1,
            stepNr: 3,
            content:
                'Once the rice is al dente, fold in the grated parmesan and rest for two minutes before serving.'),
      ],
    ),

    //mock recipe 2, taken from seeded data
    Recipe(
      recipeId: 2,
      title: 'Caprese Pasta Salad',
      description:
          'A fresh and vibrant cold pasta salad with cherry tomatoes, mini mozzarella, and basil.',
      cuisineType: 'italian',
      prepTimeMins: 15,
      cookingTimeMins: 15,
      servingSize: 6,
      ingredients: const [
        RecipeIngredient(
            ingredientId: 106,
            recipeId: 2,
            nameRaw: 'Cavatappi pasta',
            quantity: 225,
            unit: 'g',
            sortOrder: 1),
        RecipeIngredient(
            ingredientId: 107,
            recipeId: 2,
            nameRaw: 'Cherry tomatoes, halved',
            quantity: 450,
            unit: 'g',
            sortOrder: 2),
        RecipeIngredient(
            ingredientId: 108,
            recipeId: 2,
            nameRaw: 'Mini mozzarella balls',
            quantity: 150,
            unit: 'g',
            sortOrder: 3),
        RecipeIngredient(
            ingredientId: 109,
            recipeId: 2,
            nameRaw: 'Fresh basil leaves',
            quantity: 40,
            unit: 'g',
            sortOrder: 4),
      ],
      steps: const [
        RecipeStep(
            stepId: 204,
            recipeId: 2,
            stepNr: 1,
            content:
                'Cook the cavatappi pasta until just past al dente, drain, and toss with olive oil to cool.'),
        RecipeStep(
            stepId: 205,
            recipeId: 2,
            stepNr: 2,
            content:
                'Whisk olive oil, lemon juice, balsamic vinegar, garlic, salt and pepper into a dressing.'),
        RecipeStep(
            stepId: 206,
            recipeId: 2,
            stepNr: 3,
            content:
                'Combine the cooled pasta with the tomatoes, mozzarella and basil, dress, and toss to coat.'),
      ],
    ),
  ];

  @override
  Future<List<Recipe>> getRecipes() async {
    // await Future.delayed(const Duration(milliseconds: 500));
    return _recipes;
  }

  @override
  Future<Recipe> getRecipeById(int id) async {
    try {
      return _recipes.firstWhere((r) => r.recipeId == id);
    } catch (_) {
      throw StateError('Recipe $id not found in mock data');
    }
  }

  @override
  Future<void> addRecipe(Recipe recipe) async {
    //mock only, the data isnt saved
    // await Future.delayed(const Duration(milliseconds: 300));
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
      'southeast_asian',
      'middle_eastern',
      'south_african',
      'thai',
      'other',
    ];
  }
}
