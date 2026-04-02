import 'package:flutter/foundation.dart';
import 'package:myhome/src/utils/week.dart';
import 'recipe.dart';

@immutable
class PlannedRecipe {
  final String id;
  final Recipe recipe;
  final int quantity;
  final Week schedule;

  const PlannedRecipe({
    required this.id,
    required this.recipe,
    required this.quantity,
    required this.schedule,
  });

  PlannedRecipe copyWith({
    String? id,
    Recipe? recipe,
    int? quantity,
    Week? schedule,
  }) =>
      PlannedRecipe(
        id: id ?? this.id,
        recipe: recipe ?? this.recipe,
        quantity: quantity ?? this.quantity,
        schedule: schedule ?? this.schedule,
      );

  PlannedRecipe setSchedule(Week day) => copyWith(schedule: day);
  PlannedRecipe setQuantity(int qty) => copyWith(quantity: qty);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedRecipe &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          recipe == other.recipe &&
          quantity == other.quantity &&
          schedule == other.schedule;

  @override
  int get hashCode => Object.hash(id, recipe, quantity, schedule);
}
