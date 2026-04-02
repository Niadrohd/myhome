import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/src/models/planned_recipe.dart';
import 'package:myhome/src/providers/household_providers.dart';
import 'package:myhome/src/providers/planned_recipes_provider.dart';

class PortionsNumberWidget extends ConsumerWidget {
  const PortionsNumberWidget({super.key, required this.plannedRecipe});
  final PlannedRecipe plannedRecipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxValue = 10;
    final minValue = 0;

    List<PopupMenuItem> picker() {
      return List.generate(maxValue - minValue + 1, (i) {
        final value = minValue + i;
        return PopupMenuItem(
          value: value,
          onTap: () async {
            final hid = ref.read(currentHouseholdIdProvider).value;
            if (hid == null) return;
            await ref
                .read(plannedRecipesRepositoryProvider)
                .changeRecipeQuantity(hid, plannedRecipe.id, value);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value.toString()),
              if (value == plannedRecipe.quantity)
                const Icon(Icons.check),
            ],
          ),
        );
      });
    }

    return SizedBox(
      width: 50,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: PopupMenuButton(
          itemBuilder: (BuildContext context) {
            final items = [
              const PopupMenuItem(child: Text('Couverts')),
              ...picker(),
            ];
            return items;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                plannedRecipe.quantity.toString(),
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.restaurant),
            ],
          ),
        ),
      ),
    );
  }
}
