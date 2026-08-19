import 'package:flutter/foundation.dart';
import 'package:myhome/src/models/planned_recipe.dart';
import 'package:myhome/src/models/recipe.dart';
import 'package:myhome/src/utils/unit.dart';

@immutable
class ShoppingListEntry {
  final String displayName;
  final Map<Unit, double> quantitiesByUnit;

  const ShoppingListEntry({
    required this.displayName,
    required this.quantitiesByUnit,
  });
}

List<ShoppingListEntry> calculateShoppingList({
  required List<PlannedRecipe> plannedRecipes,
  required List<Recipe> recipes,
}) {
  final recipesById = {for (final recipe in recipes) recipe.id: recipe};
  final quantitiesByKey = <String, Map<Unit, double>>{};
  final displayNameByKey = <String, String>{};

  for (final planned in plannedRecipes) {
    final recipe = recipesById[planned.recipeId];
    if (recipe == null || recipe.portions <= 0) continue;
    final scale = planned.quantity / recipe.portions;

    for (final ingredient in recipe.ingredients.ingredientsList) {
      final key = _normalizeName(ingredient.name);
      displayNameByKey.putIfAbsent(key, () => ingredient.name.trim());
      final quantitiesByUnit = quantitiesByKey.putIfAbsent(key, () => {});

      final quantity = ingredient.quantity;
      if (quantity == null || ingredient.unit == Unit.none) {
        quantitiesByUnit.putIfAbsent(Unit.none, () => 0);
      } else {
        quantitiesByUnit.update(
          ingredient.unit,
          (existing) => existing + quantity * scale,
          ifAbsent: () => quantity * scale,
        );
      }
    }
  }

  final entries = quantitiesByKey.entries
      .map((entry) => ShoppingListEntry(
            displayName: displayNameByKey[entry.key]!,
            quantitiesByUnit: entry.value,
          ))
      .toList()
    ..sort((a, b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

  return entries;
}

String _normalizeName(String name) {
  final normalized = name.trim().toLowerCase();
  if (normalized.length > 1 && normalized.endsWith('s')) {
    return normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}
