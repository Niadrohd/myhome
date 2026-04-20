import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/src/providers/todo_lists_provider.dart';
import 'package:myhome/src/providers/household_providers.dart';
import 'package:myhome/theme/colors.dart';

class TodoListDetailsPage extends HookConsumerWidget {
  final String listId;

  const TodoListDetailsPage({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoListAsync = ref.watch(todoListProvider(listId));

    return todoListAsync == null
        ? Scaffold(
            appBar: AppBar(
              title: const Text('List Not Found'),
              backgroundColor: MyColors.turquoise,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('Todo list not found'),
            ),
          )
        : TodoListDetailsContent(
            todoList: todoListAsync,
            listId: listId,
          );
  }
}

class TodoListDetailsContent extends ConsumerStatefulWidget {
  final dynamic todoList;
  final String listId;

  const TodoListDetailsContent({
    super.key,
    required this.todoList,
    required this.listId,
  });

  @override
  ConsumerState<TodoListDetailsContent> createState() =>
      _TodoListDetailsContentState();
}

class _TodoListDetailsContentState
    extends ConsumerState<TodoListDetailsContent> {
  late TextEditingController _newItemController;

  @override
  void initState() {
    super.initState();
    _newItemController = TextEditingController();
  }

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedItems = widget.todoList.sortedItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todoList.name),
        backgroundColor: MyColors.turquoise,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // New item input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newItemController,
                    decoration: InputDecoration(
                      hintText: 'Add a new task...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (value) {
                      _addNewItem();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addNewItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll<Color>(MyColors.turquoise),
                    foregroundColor:
                        WidgetStatePropertyAll<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Items list
          Expanded(
            child: sortedItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No tasks yet. Add one to get started!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedItems.length,
                    itemBuilder: (context, index) {
                      final item = sortedItems[index];
                      final isCompleted = item.isCompleted;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        color: isCompleted
                            ? Colors.grey[200]
                            : Colors.white,
                        child: ListTile(
                          leading: Checkbox(
                            value: isCompleted,
                            onChanged: (_) {
                              _toggleItemCompletion(item.id);
                            },
                          ),
                          title: Text(
                            item.text,
                            style: TextStyle(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: isCompleted
                                  ? Colors.grey[600]
                                  : Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              _deleteItem(item.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewItem() async {
    if (_newItemController.text.isEmpty) return;

    final householdId = ref.read(currentHouseholdIdProvider).value;
    if (householdId == null) return;

    final repo = ref.read(todosRepositoryProvider);
    await repo.addItemToList(
      householdId,
      widget.listId,
      _newItemController.text,
    );

    _newItemController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task added'),
      ),
    );
  }

  Future<void> _toggleItemCompletion(String itemId) async {
    final householdId = ref.read(currentHouseholdIdProvider).value;
    if (householdId == null) return;

    final repo = ref.read(todosRepositoryProvider);
    await repo.toggleItemCompletion(householdId, widget.listId, itemId);
  }

  Future<void> _deleteItem(String itemId) async {
    final householdId = ref.read(currentHouseholdIdProvider).value;
    if (householdId == null) return;

    final repo = ref.read(todosRepositoryProvider);
    await repo.deleteItem(householdId, widget.listId, itemId);
  }
}
