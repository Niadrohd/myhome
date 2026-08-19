import 'package:flutter/foundation.dart';
import 'package:myhome/src/utils/unit.dart';

@immutable
class Ingredient {
  final String name;
  final double? quantity;
  final Unit unit;

  const Ingredient({
    required this.name,
    this.quantity,
    this.unit = Unit.none,
  });

  Ingredient copyWith({String? name, double? quantity, Unit? unit}) =>
      Ingredient(
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          quantity == other.quantity &&
          unit == other.unit;

  @override
  int get hashCode => Object.hash(name, quantity, unit);
}
