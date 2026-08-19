import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/providers/shopping_list_provider.dart';
import 'package:myhome/src/utils/shopping_list_calculator.dart';
import 'package:myhome/src/utils/unit.dart';
import 'package:myhome/theme/colors.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListAsync = ref.watch(shoppingListProvider);
    final str = context.l;

    return Scaffold(
      appBar: AppBar(
        title: Text(str.shoppingListTitle),
        backgroundColor: MyColors.turquoise,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: shoppingListAsync.when(
        data: (entries) => entries.isEmpty
            ? Center(child: Text(str.noPlannedRecipesForShoppingList))
            : ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    _ShoppingListTile(entry: entries[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class _ShoppingListTile extends StatelessWidget {
  const _ShoppingListTile({required this.entry});
  final ShoppingListEntry entry;

  @override
  Widget build(BuildContext context) {
    final quantities = entry.quantitiesByUnit.entries
        .where((e) => e.key != Unit.none)
        .map((e) => '${_formatQuantity(e.value)}${e.key.shortLabel}')
        .join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 160.0,
            child: Text(
              entry.displayName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (quantities.isNotEmpty)
            Text(
              quantities,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }

  String _formatQuantity(double quantity) {
    return quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toString();
  }
}
