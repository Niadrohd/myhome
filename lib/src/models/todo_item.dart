import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class TodoItem {
  final String id;
  final String text;
  final bool isCompleted;
  final DateTime createdAt;

  const TodoItem({
    required this.id,
    required this.text,
    required this.isCompleted,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    DateTime createdAt = DateTime.now();
    final createdAtValue = json['createdAt'];
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    }

    return TodoItem(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  TodoItem copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'TodoItem(id: $id, text: $text, isCompleted: $isCompleted, createdAt: $createdAt)';

  @override
  bool operator ==(covariant TodoItem other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.text == text &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^ text.hashCode ^ isCompleted.hashCode ^ createdAt.hashCode;
}
