import 'package:flutter/foundation.dart';
import 'todo_item.dart';

@immutable
class TodoList {
  final String id;
  final String name;
  final List<TodoItem> items;
  final DateTime createdAt;

  const TodoList({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
  });

  // Get items sorted: uncompleted first, then completed
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
    };
  }

  factory TodoList.fromJson(Map<String, dynamic> json, String id) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((item) => TodoItem.fromJson(item))
        .toList();

    return TodoList(
      id: id,
      name: json['name'] as String? ?? '',
      items: itemsList,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  TodoList copyWith({
    String? id,
    String? name,
    List<TodoItem>? items,
    DateTime? createdAt,
  }) {
    return TodoList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'TodoList(id: $id, name: $name, items: $items, createdAt: $createdAt)';

  @override
  bool operator ==(covariant TodoList other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        listEquals(other.items, items) &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ items.hashCode ^ createdAt.hashCode;
}
