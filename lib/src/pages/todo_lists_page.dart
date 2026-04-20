import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/src/my_navigator.dart';
import 'package:myhome/src/providers/todo_lists_provider.dart';
import 'package:myhome/src/providers/household_providers.dart';
import 'package:myhome/theme/colors.dart';

class TodoListsPage extends HookConsumerWidget {
  const TodoListsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoListsAsync = ref.watch(todoListsProvider);

    return MyNavigator(
      title: 'Todo Lists',
      page: todoListsAsync.when(
        data: (todoLists) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showCreateListDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Create New List'),
                style: const ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll<Color>(MyColors.turquoise),
                  foregroundColor:
                      WidgetStatePropertyAll<Color>(Colors.white),
                ),
              ),
            ),
            Expanded(
              child: todoLists.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No todo lists yet. Create one to get started!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: todoLists.length,
                      itemBuilder: (context, index) {
                        final list = todoLists[index];
                        final itemCount = list.items.length;
                        final completedCount =
                            list.items.where((item) => item.isCompleted).length;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: ListTile(
                            title: Text(list.name),
                            subtitle: Text(
                              '$completedCount/$itemCount items completed',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showRenameListDialog(context, ref, list),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteTodoList(
                                    context,
                                    ref,
                                    list.id,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/todo_list_details',
                                arguments: {'listId': list.id},
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'List name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final householdId =
                    ref.read(currentHouseholdIdProvider).value;
                if (householdId != null) {
                  final repo = ref.read(todosRepositoryProvider);
                  await repo.createTodoList(householdId, controller.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('List "${controller.text}" created'),
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameListDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic list,
  ) {
    final controller = TextEditingController(text: list.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'New list name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final householdId =
                    ref.read(currentHouseholdIdProvider).value;
                if (householdId != null) {
                  final repo = ref.read(todosRepositoryProvider);
                  await repo.renameTodoList(
                    householdId,
                    list.id,
                    controller.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('List renamed'),
                    ),
                  );
                }
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTodoList(
    BuildContext context,
    WidgetRef ref,
    String listId,
  ) async {
    final householdId = ref.read(currentHouseholdIdProvider).value;
    if (householdId != null) {
      final repo = ref.read(todosRepositoryProvider);
      await repo.deleteTodoList(householdId, listId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('List deleted'),
        ),
      );
    }
  }
}
