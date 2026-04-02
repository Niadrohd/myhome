import 'package:flutter/foundation.dart';

@immutable
class Ingredient {
  final String name;
  final String quantity;

  const Ingredient({required this.name, required this.quantity});

  Ingredient copyWith({String? name, String? quantity}) => Ingredient(
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(name, quantity);
}
