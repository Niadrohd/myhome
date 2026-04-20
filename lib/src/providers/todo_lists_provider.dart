import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myhome/src/models/todo_list.dart';
import 'package:myhome/src/repositories/todos_repository.dart';
import 'firebase_providers.dart';
import 'household_providers.dart';

final todosRepositoryProvider = Provider<TodosRepository>((ref) {
  return TodosRepository(ref.watch(firestoreProvider));
});

final todoListsProvider = StreamProvider<List<TodoList>>((ref) {
  final hidAsync = ref.watch(currentHouseholdIdProvider);
  final repo = ref.watch(todosRepositoryProvider);

  return hidAsync.when(
    data: (hid) =>
        hid == null ? const Stream.empty() : repo.watchTodoLists(hid),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Provider to get a specific todo list
final todoListProvider = Provider.family<TodoList?, String>((ref, listId) {
  final lists = ref.watch(todoListsProvider);
  return lists.whenData((list) {
    return list.firstWhereOrNull((l) => l.id == listId);
  }).value;
});

extension FirstWhereOrNullExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

