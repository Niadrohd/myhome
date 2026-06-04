import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'todo_item.dart';

@immutable
class TodoList {
  final String id;
  final String name;
  final List<TodoItem> items;
  final DateTime createdAt;

  /// Explicit display order. `-1` means the order has not been set yet
  /// (legacy lists created before ordering existed); these sort after the
  /// explicitly ordered lists, by creation date.
  final int order;

  const TodoList({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
    this.order = -1,
  });

  /// Items for display: incomplete first, then completed, each group keeping
  /// its manual (stored) order. Reordering persists into [items]; this getter
  /// only partitions by completion for display.
  List<TodoItem> get sortedItems {
    final uncompleted = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();
    return [...uncompleted, ...completed];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'order': order,
    };
  }

  factory TodoList.fromJson(Map<String, dynamic> json, String id) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((item) => TodoItem.fromJson(item))
        .toList();

    DateTime createdAt = DateTime.now();
    final createdAtValue = json['createdAt'];
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    }

    return TodoList(
      id: id,
      name: json['name'] as String? ?? '',
      items: itemsList,
      createdAt: createdAt,
      order: (json['order'] as num?)?.toInt() ?? -1,
    );
  }

  TodoList copyWith({
    String? id,
    String? name,
    List<TodoItem>? items,
    DateTime? createdAt,
    int? order,
  }) {
    return TodoList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
    );
  }

  @override
  String toString() =>
      'TodoList(id: $id, name: $name, items: $items, createdAt: $createdAt, order: $order)';

  @override
  bool operator ==(covariant TodoList other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        listEquals(other.items, items) &&
        other.createdAt == createdAt &&
        other.order == order;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      items.hashCode ^
      createdAt.hashCode ^
      order.hashCode;
}
