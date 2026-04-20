import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myhome/src/components/add_fab.dart';
import 'package:myhome/src/components/new_item_dialog.dart';
import 'package:myhome/src/my_navigator.dart';
import 'package:myhome/src/providers/household_providers.dart';
import 'package:myhome/src/providers/items_provider.dart';
import 'package:myhome/theme/colors.dart';

class StockPage extends ConsumerWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    final hidAsync = ref.watch(currentHouseholdIdProvider);
    final repo = ref.watch(itemsRepositoryProvider);

    return MyNavigator(
      title: 'Stocks',
      page: Stack(
        children: [
          itemsAsync.when(
            data: (items) => ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final it = items[i];
                return Dismissible(
                  key: Key(it.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    final hid = hidAsync.value;
                    if (hid == null) return;
                    repo.deleteItem(hid, it.id);
                  },
                  background: Container(),
                  secondaryBackground: Container(
                    color: MyColors.dismissibleDeleteColor,
                    alignment: Alignment.centerRight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Delete',
                            style: TextStyle(
                                fontSize: 18, color: Colors.white)),
                        const Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 15)),
                        const Icon(Icons.delete, color: Colors.white),
                      ],
                    ),
                  ),
                  child: ListTile(
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: it.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' ${it.details}',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text('${it.quantity} x ${it.unit}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () async {
                            final hid = hidAsync.value;
                            if (hid == null) return;
                            await repo.changeQuantity(hid, it.id, -1);
                          },
                        ),
                        Text(it.quantity.toString(),
                            style: const TextStyle(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final hid = hidAsync.value;
                            if (hid == null) return;
                            await repo.changeQuantity(hid, it.id, 1);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur: $e')),
          ),
          AddFab(
            onPressed: () {
              final hid = hidAsync.value;
              if (hid == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Household ID is null')),
                );
                return;
              }
              showDialog(
                context: context,
                builder: (context) => NewItemDialog(hid: hid),
              );
            },
          ),
        ],
      ),
    );
  }
}
