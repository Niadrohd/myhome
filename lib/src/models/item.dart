import 'package:flutter/foundation.dart';

@immutable
class Item {
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final String details;

  const Item({
    required this.id,
    required this.name,
    this.quantity = 0,
    this.unit = 'pcs',
    this.details = '',
  });

  Item copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    String? details,
  }) =>
      Item(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        details: details ?? this.details,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          quantity == other.quantity &&
          unit == other.unit &&
          details == other.details;

  @override
  int get hashCode => Object.hash(id, name, quantity, unit, details);
}
