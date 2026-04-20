enum RoutesName {
  recipesList,
  createRecipe,
  menu,
  recipeDetails,
  stock,
  todoLists,
}

extension RoutesNameExtension on RoutesName {
  String get path {
    switch (this) {
      case RoutesName.recipesList:
        return '/recipes_list';
      case RoutesName.createRecipe:
        return '/create_recipe';
      case RoutesName.menu:
        return '/menu';
      case RoutesName.recipeDetails:
        return '/recipe_details';
      case RoutesName.stock:
        return '/stock';
      case RoutesName.todoLists:
        return '/todo_lists';
    }
  }
}
