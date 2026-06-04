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
    return _todoListsRef(householdId).snapshots().map((s) {
      final lists =
          s.docs.map((d) => TodoList.fromJson(d.data(), d.id)).toList();
      lists.sort(_compareLists);
      return lists;
    });
  }

  /// Sorts by explicit [TodoList.order] ascending. Lists without an order set
  /// (`-1`, legacy) sort after the ordered ones, newest first.
  static int _compareLists(TodoList a, TodoList b) {
    final ao = a.order;
    final bo = b.order;
    if (ao >= 0 && bo >= 0) return ao.compareTo(bo);
    if (ao >= 0) return -1;
    if (bo >= 0) return 1;
    return b.createdAt.compareTo(a.createdAt);
  }

  Future<void> createTodoList(String householdId, String name) async {
    final snap = await _todoListsRef(householdId).get();
    await _todoListsRef(householdId).add({
      'name': name.trim(),
      'items': <Map<String, dynamic>>[],
      'createdAt': FieldValue.serverTimestamp(),
      // Append at the end of the current lists.
      'order': snap.size,
    });
  }

  /// Persists a new ordering of the lists. [orderedListIds] must be the list
  /// ids in their desired display order.
  Future<void> reorderTodoLists(
    String householdId,
    List<String> orderedListIds,
  ) {
    final batch = _fs.batch();
    for (var i = 0; i < orderedListIds.length; i++) {
      batch.update(
        _todoListsRef(householdId).doc(orderedListIds[i]),
        {'order': i},
      );
    }
    return batch.commit();
  }

  /// Persists a new ordering of the items within a list. [orderedItemIds] must
  /// be the item ids in their desired display order.
  Future<void> reorderItems(
    String householdId,
    String listId,
    List<String> orderedItemIds,
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

      final byId = {for (final item in items) item.id: item};
      final reordered = <TodoItem>[
        for (final id in orderedItemIds)
          if (byId.containsKey(id)) byId[id]!,
      ];
      // Safety net: keep any items not mentioned in the new order.
      for (final item in items) {
        if (!orderedItemIds.contains(item.id)) reordered.add(item);
      }

      tx.update(ref, {
        'items': reordered.map((item) => item.toJson()).toList(),
      });
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
