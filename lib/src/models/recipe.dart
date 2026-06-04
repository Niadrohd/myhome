import 'package:flutter/foundation.dart';
import 'ingredient.dart';
import 'ingredients.dart';

@immutable
class Recipe {
  final String id;
  final String name;
  final int preparationTime;
  final int cookingTime;
  final String link;
  final Ingredients ingredients;
  final int portions;

  const Recipe({
    required this.id,
    required this.name,
    required this.preparationTime,
    required this.cookingTime,
    required this.link,
    required this.ingredients,
    this.portions = 2,
  });

  Recipe copyWith({
    String? id,
    String? name,
    int? preparationTime,
    int? cookingTime,
    String? link,
    Ingredients? ingredients,
    int? portions,
  }) =>
      Recipe(
        id: id ?? this.id,
        name: name ?? this.name,
        preparationTime: preparationTime ?? this.preparationTime,
        cookingTime: cookingTime ?? this.cookingTime,
        link: link ?? this.link,
        ingredients: ingredients ?? this.ingredients,
        portions: portions ?? this.portions,
      );

  Recipe removeIngredient(Ingredient ingredient) {
    return copyWith(
      ingredients: Ingredients(
        ingredients.ingredientsList.where((i) => i != ingredient).toList(),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          preparationTime == other.preparationTime &&
          cookingTime == other.cookingTime &&
          link == other.link &&
          ingredients == other.ingredients &&
          portions == other.portions;

  @override
  int get hashCode => Object.hash(
      id, name, preparationTime, cookingTime, link, ingredients, portions);
}
