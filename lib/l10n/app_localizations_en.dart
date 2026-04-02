// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyHome';

  @override
  String get newRecipe => 'New recipe';

  @override
  String savedRecipeMessage(String name) {
    return 'Saved recipe: $name';
  }

  @override
  String get recipeName => 'Recipe name';

  @override
  String cookingTime(String unit) {
    return 'Cooking time $unit';
  }

  @override
  String preparationTime(String unit) {
    return 'Preparation time $unit';
  }

  @override
  String get recipeLink => 'Link to the recipe';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get ingredient => 'Ingredient';

  @override
  String get quantity => 'Quantity';

  @override
  String get save => 'Save';

  @override
  String get invalidInputMessage => 'Please enter a valid text';

  @override
  String get emptyIngredientMessage => 'Can\'t add a quantity without specifying an ingredient';

  @override
  String get myRecipes => 'My recipes';

  @override
  String get noRecipesYetMessage => 'No registered recipe yet';

  @override
  String cookingTimePreviewMessage(String Time) {
    return 'Cooking time: $Time';
  }

  @override
  String preparationTimePreviewMessage(String Time) {
    return 'Preparation time: $Time';
  }

  @override
  String get delete => 'Delete';

  @override
  String get unplanned => 'Unplanned';

  @override
  String get myMenu => 'My menu';

  @override
  String numberOfMeals(String number) {
    return '$number meals';
  }

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get unscheduled => 'Unscheduled';

  @override
  String get scheduleRecipeMessage => 'Schedule';

  @override
  String get register => 'Register';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get addNewItemTitle => 'Add New Item';

  @override
  String get itemNameLabel => 'Name';

  @override
  String get itemDetailsLabel => 'Details';

  @override
  String get itemQuantityLabel => 'Quantity';

  @override
  String get itemUnitLabel => 'Unit';

  @override
  String get saveButtonLabel => 'Save';

  @override
  String get cancelButtonLabel => 'Cancel';
}
