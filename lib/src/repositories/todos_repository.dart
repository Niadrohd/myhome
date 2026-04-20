import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:myhome/src/models/todo_list.dart';
import 'package:myhome/src/models/todo_item.dart';

class TodosRepository {
  TodosRepository(this._fs);
  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> _todoListsRef(String householdId) =>
      _fs.collection('households').doc(householdId).collection('todoLists');

  Stream<List<TodoList>> watchTodoLists(String householdId) {
    return _todoListsRef(householdId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => TodoList.fromJson(d.data(), d.id)).toList());
  }

  Future<void> createTodoList(String householdId, String name) {
    return _todoListsRef(householdId).add({
      'name': name.trim(),
      'items': <Map<String, dynamic>>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTodoList(String householdId, String listId) {
    return _todoListsRef(householdId).doc(listId).delete();
  }

  Future<void> renameTodoList(
    String householdId,
    String listId,
    String newName,
  ) {
    return _todoListsRef(householdId).doc(listId).update({
      'name': newName.trim(),
    });
  }

  Future<void> addItemToList(
    String householdId,
    String listId,
    String itemText,
  ) async {
    final ref = _todoListsRef(householdId).doc(listId);
    await _fs.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) return;

      final items = (data['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => TodoItem.fromJson(item))
          .toList();

      final newItem = TodoItem(
        id: const Uuid().v4(),
        text: itemText.trim(),
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      items.add(newItem);

      tx.update(ref, {
        'items': items.map((item) => item.toJson()).toList(),
      });
    });
  }

  Future<void> toggleItemCompletion(
    String householdId,
    String listId,
    String itemId,
  ) async {
    final ref = _todoListsRef(householdId).doc(listId);
    await _fs.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) return;

      final items = (data['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => TodoItem.fromJson(item))
          .toList();

      final itemIndex = items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        items[itemIndex] = items[itemIndex].copyWith(
          isCompleted: !items[itemIndex].isCompleted,
        );
      }

      tx.update(ref, {
        'items': items.map((item) => item.toJson()).toList(),
      });
    });
  }

  Future<void> deleteItem(
    String householdId,
    String listId,
    String itemId,
  ) async {
    final ref = _todoListsRef(householdId).doc(listId);
    await _fs.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) return;

      final items = (data['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => TodoItem.fromJson(item))
          .toList();

      items.removeWhere((item) => item.id == itemId);

      tx.update(ref, {
        'items': items.map((item) => item.toJson()).toList(),
      });
    });
  }

  Future<void> updateItemText(
    String householdId,
    String listId,
    String itemId,
    String newText,
  ) async {
    final ref = _todoListsRef(householdId).doc(listId);
    await _fs.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) return;

      final items = (data['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => TodoItem.fromJson(item))
          .toList();

      final itemIndex = items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        items[itemIndex] = items[itemIndex].copyWith(text: newText.trim());
      }

      tx.update(ref, {
        'items': items.map((item) => item.toJson()).toList(),
      });
    });
  }
}
