//define every name route as a constant string
//eg /login. nothing in app types string, strings are referenced from here
class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String guidedDiscovery = '/guided-discovery';
  static const String pantry = '/pantry';
  static const String vault = '/vault';
  static const String vaultMembers = '/vault/:vaultId/members';
  static const String recipeEdit = '/recipe/:id/edit';
  static const String profile = '/profile';
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminFlagDetail = '/admin/flags/:id';
  static const String addIngredient = '/pantry/add';
  static const String showcase = '/component_showcase';
  static const String signup = '/signup';
  static const String addRecipe = '/add-recipe';
  static const String recipeDetail = '/recipe/:id';
  static const String cookMode = '/recipe/:id/cook';
  static const String discovery = '/discovery';
  static const String shoppingLists = '/shopping-lists';
  static const String shoppingListDetail = '/shopping-lists/:id';
  static const String shoppingListAddItem = '/shopping-lists/:id/add-item';
  static const String help = '/help';
  static const String editRecipe = '/edit-recipe/:id';
  static const recommendationSettings = '/recommendation-settings';

  static String cookModeLocation(int recipeId, {int? stepIndex}) {
    return Uri(
      path: '/recipe/$recipeId/cook',
      queryParameters:
          stepIndex == null ? null : {'step': stepIndex.toString()},
    ).toString();
  }
}
