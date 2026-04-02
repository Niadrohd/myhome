import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'ingredient.dart';

@immutable
class Ingredients {
  final List<Ingredient> ingredientsList;

  const Ingredients(this.ingredientsList);

  Ingredients operator +(Ingredients others) {
    return Ingredients(ingredientsList + others.ingredientsList);
  }

  List<String> getNames() {
    return ingredientsList.map((ingredient) => ingredient.name).toList();
  }

  String formattingToString() {
    var str = '';
    for (var ingredient in ingredientsList) {
      str = '$str ${ingredient.name}: ${ingredient.quantity};';
    }
    return str.trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredients &&
          runtimeType == other.runtimeType &&
          _listEquals(ingredientsList, other.ingredientsList);

  bool _listEquals(List<Ingredient> a, List<Ingredient> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(ingredientsList);
}
