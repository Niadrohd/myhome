import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myhome/src/models/ingredient.dart';
import 'package:myhome/src/models/ingredients.dart';
import 'package:myhome/src/models/recipe.dart';
import 'package:myhome/src/utils.dart';
import 'package:myhome/src/utils/legacy_ingredient_quantity.dart';
import 'package:myhome/src/utils/unit.dart';

class RecipesRepository {
  RecipesRepository(this._fs);
  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> _recipesRef(String householdId) =>
      _fs.collection('households').doc(householdId).collection('recipes');

  Stream<List<Recipe>> watchRecipes(String householdId) {
    return _recipesRef(householdId)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  Future<void> addRecipe(
    String householdId, {
    required String name,
    required int preparationTime,
    required int cookingTime,
    required String link,
    required Ingredients ingredients,
    required int portions,
  }) {
    return _recipesRef(householdId).add({
      'name': name.trim().capitalize(),
      'preparationTime': preparationTime,
      'cookingTime': cookingTime,
      'link': link.trim(),
      'portions': portions,
      'ingredients': ingredients.ingredientsList
          .map((i) => {
                'name': i.name,
                'quantity': i.quantity,
                'unit': i.unit.name,
              })
          .toList(),
    });
  }

  Future<void> updateRecipe(
    String householdId,
    String recipeId, {
    required String name,
    required int preparationTime,
    required int cookingTime,
    required String link,
    required Ingredients ingredients,
    required int portions,
  }) {
    return _recipesRef(householdId).doc(recipeId).update({
      'name': name.trim().capitalize(),
      'preparationTime': preparationTime,
      'cookingTime': cookingTime,
      'link': link.trim(),
      'portions': portions,
      'ingredients': ingredients.ingredientsList
          .map((i) => {
                'name': i.name,
                'quantity': i.quantity,
                'unit': i.unit.name,
              })
          .toList(),
    });
  }

  Future<void> deleteRecipe(String householdId, String recipeId) {
    return _recipesRef(householdId).doc(recipeId).delete();
  }

  Recipe _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data()!;
    final ingredientsData = data['ingredients'] as List<dynamic>? ?? [];
    final ingredients = Ingredients(
      ingredientsData
          .whereType<Map<String, dynamic>>()
          .map((i) {
            final (quantity, unit) = _ingredientQuantityAndUnit(i);
            return Ingredient(
              name: (i['name'] as String?) ?? '',
              quantity: quantity,
              unit: unit,
            );
          })
          .toList(),
    );
    return Recipe(
      id: d.id,
      name: (data['name'] as String?) ?? '',
      preparationTime: (data['preparationTime'] as num?)?.toInt() ?? 0,
      cookingTime: (data['cookingTime'] as num?)?.toInt() ?? 0,
      link: (data['link'] as String?) ?? '',
      ingredients: ingredients,
      portions: (data['portions'] as num?)?.toInt() ?? 2,
    );
  }

  /// Reads the structured `quantity`/`unit` fields, falling back to
  /// best-effort parsing of the old free-text `quantity` string format for
  /// documents saved before ingredients had a `unit` field.
  (double?, Unit) _ingredientQuantityAndUnit(Map<String, dynamic> i) {
    if (i.containsKey('unit')) {
      final quantity = (i['quantity'] as num?)?.toDouble();
      final unit = Unit.values.asNameMap()[i['unit'] as String?] ?? Unit.none;
      return (quantity, unit);
    }
    final legacyQuantity = i['quantity'];
    if (legacyQuantity is String) {
      return LegacyIngredientQuantity.parse(legacyQuantity);
    }
    return (null, Unit.none);
  }
}
