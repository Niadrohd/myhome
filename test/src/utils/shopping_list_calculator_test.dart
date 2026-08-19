import 'package:flutter_test/flutter_test.dart';
import 'package:myhome/src/models/ingredient.dart';
import 'package:myhome/src/models/ingredients.dart';
import 'package:myhome/src/models/planned_recipe.dart';
import 'package:myhome/src/models/recipe.dart';
import 'package:myhome/src/utils/shopping_list_calculator.dart';
import 'package:myhome/src/utils/unit.dart';
import 'package:myhome/src/utils/week.dart';

Recipe _recipe(
  String id,
  int portions,
  List<Ingredient> ingredients,
) {
  return Recipe(
    id: id,
    name: 'Recipe $id',
    preparationTime: 0,
    cookingTime: 0,
    link: '',
    ingredients: Ingredients(ingredients),
    portions: portions,
  );
}

PlannedRecipe _planned(String recipeId, int quantity) {
  return PlannedRecipe(
    id: 'planned-$recipeId',
    recipeId: recipeId,
    quantity: quantity,
    schedule: Week.monday,
  );
}

void main() {
  test('scales ingredient quantities by wanted/portions ratio', () {
    final recipe = _recipe('r1', 2, [
      const Ingredient(name: 'Flour', quantity: 200, unit: Unit.g),
    ]);
    final result = calculateShoppingList(
      plannedRecipes: [_planned('r1', 4)],
      recipes: [recipe],
    );

    expect(result, hasLength(1));
    expect(result.first.displayName, 'Flour');
    expect(result.first.quantitiesByUnit[Unit.g], 400);
  });

  test('merges same ingredient across recipes ignoring case/trim/plural', () {
    final recipeA = _recipe('a', 2, [
      const Ingredient(name: ' Carrot ', quantity: 100, unit: Unit.g),
    ]);
    final recipeB = _recipe('b', 2, [
      const Ingredient(name: 'CARROTS', quantity: 50, unit: Unit.g),
    ]);

    final result = calculateShoppingList(
      plannedRecipes: [_planned('a', 2), _planned('b', 2)],
      recipes: [recipeA, recipeB],
    );

    expect(result, hasLength(1));
    expect(result.first.displayName, 'Carrot');
    expect(result.first.quantitiesByUnit[Unit.g], 150);
  });

  test('does not merge unrelated ingredients that share a prefix', () {
    final recipe = _recipe('r1', 1, [
      const Ingredient(name: 'Egg', quantity: 2, unit: Unit.piece),
      const Ingredient(name: 'Eggplant', quantity: 1, unit: Unit.piece),
    ]);

    final result = calculateShoppingList(
      plannedRecipes: [_planned('r1', 1)],
      recipes: [recipe],
    );

    expect(result, hasLength(2));
    expect(result.map((e) => e.displayName), ['Egg', 'Eggplant']);
  });

  test('keeps different units of the same ingredient separate', () {
    final recipeA = _recipe('a', 1, [
      const Ingredient(name: 'Milk', quantity: 1, unit: Unit.L),
    ]);
    final recipeB = _recipe('b', 1, [
      const Ingredient(name: 'Milk', quantity: 2, unit: Unit.cL),
    ]);

    final result = calculateShoppingList(
      plannedRecipes: [_planned('a', 1), _planned('b', 1)],
      recipes: [recipeA, recipeB],
    );

    expect(result, hasLength(1));
    expect(result.first.quantitiesByUnit[Unit.L], 1);
    expect(result.first.quantitiesByUnit[Unit.cL], 2);
  });

  test('ingredients with no quantity are listed but not summed', () {
    final recipe = _recipe('r1', 2, [
      const Ingredient(name: 'Salt'),
    ]);

    final result = calculateShoppingList(
      plannedRecipes: [_planned('r1', 6)],
      recipes: [recipe],
    );

    expect(result, hasLength(1));
    expect(result.first.displayName, 'Salt');
    expect(result.first.quantitiesByUnit, {Unit.none: 0});
  });

  test('ignores planned recipes whose recipe is missing or has 0 portions',
      () {
    final recipe = _recipe('r1', 0, [
      const Ingredient(name: 'Sugar', quantity: 10, unit: Unit.g),
    ]);

    final result = calculateShoppingList(
      plannedRecipes: [_planned('r1', 2), _planned('missing', 2)],
      recipes: [recipe],
    );

    expect(result, isEmpty);
  });
}
