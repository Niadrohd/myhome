// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MyHome';

  @override
  String get newRecipe => 'Nouvelle recette';

  @override
  String savedRecipeMessage(String name) {
    return 'Recette enregistrée: $name';
  }

  @override
  String get recipeName => 'Nom du plat';

  @override
  String cookingTime(String unit) {
    return 'Temps de cuisine $unit';
  }

  @override
  String preparationTime(String unit) {
    return 'Temps de preparation $unit';
  }

  @override
  String get recipeLink => 'Lien vers la recette';

  @override
  String get ingredients => 'Ingrédients';

  @override
  String get ingredient => 'Ingrédient';

  @override
  String get quantity => 'Quantité';

  @override
  String get save => 'Enregistrer';

  @override
  String get invalidInputMessage => 'Veuillez renseigner une entrée valide';

  @override
  String get emptyIngredientMessage => 'Impossible d\'ajouter une quantité sans spécifier d\'ingrédient';

  @override
  String get myRecipes => 'Mes recettes';

  @override
  String get noRecipesYetMessage => 'Pas encore de recette enregistrée';

  @override
  String cookingTimePreviewMessage(String Time) {
    return 'Temps de cuisine: $Time';
  }

  @override
  String preparationTimePreviewMessage(String Time) {
    return 'Temps de preparation: $Time';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get unplanned => 'Déprogrammer';

  @override
  String get myMenu => 'Mon menu';

  @override
  String numberOfMeals(String number) {
    return '$number repas';
  }

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get unscheduled => 'Non programmés';

  @override
  String get scheduleRecipeMessage => 'Programmer';

  @override
  String get register => 'S\'enregistrer';

  @override
  String get login => 'Se connecter';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get addNewItemTitle => 'Ajouter un nouvel article';

  @override
  String get itemNameLabel => 'Nom';

  @override
  String get itemDetailsLabel => 'Détails';

  @override
  String get itemQuantityLabel => 'Quantité';

  @override
  String get itemUnitLabel => 'Unité';

  @override
  String get saveButtonLabel => 'Enregistrer';

  @override
  String get cancelButtonLabel => 'Annuler';
}
