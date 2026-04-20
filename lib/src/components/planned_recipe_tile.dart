import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/src/components/portions_number_widget.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/models/planned_recipe.dart';
import 'package:myhome/src/providers/household_providers.dart';
import 'package:myhome/src/providers/planned_recipes_provider.dart';
import 'package:myhome/src/providers/recipes_provider.dart';
import 'package:myhome/src/utils.dart';
import 'package:myhome/src/utils/week.dart';
import 'package:myhome/src/utils/wrap_semantics.dart';
import 'package:myhome/theme/colors.dart';

class PlannedRecipeTile extends ConsumerWidget {
  const PlannedRecipeTile({super.key, required this.plannedRecipe});
  final PlannedRecipe plannedRecipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final str = context.l;
    final recipe = ref.watch(recipesProvider).value!.firstWhere(
          (r) => r.id == plannedRecipe.recipeId,
        );
    return ListTile(
      tileColor: MyColors.pastel,
      title: Text(recipe.name.capitalize()),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recipe.ingredients.getNames().join(', ')),
          Text(str.preparationTimePreviewMessage(
              recipe.preparationTime.toString())),
          Text(str.cookingTimePreviewMessage(recipe.cookingTime.toString())),
          ScheduleDrawList(recipe: plannedRecipe),
        ],
      ),
      leading: const CircleAvatar(
        foregroundImage: AssetImage('assets/images/repas_img.jpg'),
      ),
      trailing: PortionsNumberWidget(plannedRecipe: plannedRecipe),
    );
  }
}

class ScheduleDrawList extends ConsumerWidget {
  const ScheduleDrawList({super.key, required this.recipe});
  final PlannedRecipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plannedAsync = ref.watch(plannedRecipesProvider);
    final str = context.l;

    final schedule = plannedAsync.value
            ?.firstWhere(
              (pr) => pr.id == recipe.id,
              orElse: () => recipe,
            )
            .schedule ??
        recipe.schedule;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<Week>(
        initialValue: schedule,
        onSelected: (Week day) async {
          final hid = ref.read(currentHouseholdIdProvider).value;
          if (hid == null) return;
          await ref
              .read(plannedRecipesRepositoryProvider)
              .scheduleRecipe(hid, recipe.id, day);
        },
        itemBuilder: (BuildContext context) => Week.values
            .map((day) => PopupMenuItem(
                  value: day,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(day.localizedName(context)),
                      if (day == schedule) const Icon(Icons.check),
                    ],
                  ),
                ))
            .toList(),
        child: wrapSemantics(
          isTile: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(schedule == Week.other
                    ? str.scheduleRecipeMessage
                    : schedule.localizedName(context)),
                const Icon(Icons.unfold_more_outlined, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
