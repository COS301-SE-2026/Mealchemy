//define every name route as a constant string
//eg /login. nothing in app types string, strings are referenced from here
class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String guidedDiscovery = '/guided-discovery';
  static const String pantry = '/pantry';
  static const String vault = '/vault';
  static const String recipeEdit = '/recipe/:id/edit';
  static const String profile = '/profile';
  static const String addIngredient = '/pantry/add';
  static const String showcase = '/component_showcase';
  static const String signup = '/signup';
  static const String addRecipe = '/add-recipe';
  static const String recipeDetail = '/recipe/:id';
  static const String discovery = '/discovery';
  static const String shoppingLists = '/shopping-lists';
  static const String shoppingListDetail = '/shopping-lists/:id';
  static const String shoppingListAddItem = '/shopping-lists/:id/add-item';
  static const String help = '/help';
  static const String editRecipe = '/edit-recipe/:id';
}
