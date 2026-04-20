import 'package:flutter/foundation.dart';
import 'package:myhome/src/utils/week.dart';

@immutable
class PlannedRecipe {
  final String id;
  final String recipeId;
  final int quantity;
  final Week schedule;

  const PlannedRecipe({
    required this.id,
    required this.recipeId,
    required this.quantity,
    required this.schedule,
  });

  PlannedRecipe copyWith({
    String? id,
    String? recipeId,
    int? quantity,
    Week? schedule,
  }) =>
      PlannedRecipe(
        id: id ?? this.id,
        recipeId: recipeId ?? this.recipeId,
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
          recipeId == other.recipeId &&
          quantity == other.quantity &&
          schedule == other.schedule;

  @override
  int get hashCode => Object.hash(id, recipeId, quantity, schedule);
}
