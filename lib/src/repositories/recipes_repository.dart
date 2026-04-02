import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myhome/src/models/ingredient.dart';
import 'package:myhome/src/models/ingredients.dart';
import 'package:myhome/src/models/recipe.dart';

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
  }) {
    return _recipesRef(householdId).add({
      'name': name.trim(),
      'preparationTime': preparationTime,
      'cookingTime': cookingTime,
      'link': link.trim(),
      'ingredients': ingredients.ingredientsList
          .map((i) => {'name': i.name, 'quantity': i.quantity})
          .toList(),
    });
  }

  Future<void> deleteRecipe(String householdId, String recipeId) {
    return _recipesRef(householdId).doc(recipeId).delete();
  }

  Recipe _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data()!;
    final ingredientsData =
        (data['ingredients'] as List<dynamic>?) ?? [];
    final ingredients = Ingredients(
      ingredientsData
          .map((i) => Ingredient(
                name: (i['name'] as String?) ?? '',
                quantity: (i['quantity'] as String?) ?? '',
              ))
          .toList(),
    );
    return Recipe(
      id: d.id,
      name: (data['name'] as String?) ?? '',
      preparationTime: (data['preparationTime'] as num?)?.toInt() ?? 0,
      cookingTime: (data['cookingTime'] as num?)?.toInt() ?? 0,
      link: (data['link'] as String?) ?? '',
      ingredients: ingredients,
    );
  }
}
