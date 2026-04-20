import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/src/components/planned_recipe_tile.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/models/planned_recipe.dart';
import 'package:myhome/src/my_navigator.dart';
import 'package:myhome/src/providers/household_providers.dart';
import 'package:myhome/src/providers/planned_recipes_provider.dart';
import 'package:myhome/src/providers/recipes_provider.dart';
import 'package:myhome/src/utils/week.dart';
import 'package:myhome/theme/colors.dart';

class MenuPage extends HookConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plannedAsync = ref.watch(plannedRecipesProvider);
    final recipesAsync = ref.watch(recipesProvider);
    final str = context.l;

    Widget buildMenu(List<PlannedRecipe> plannedRecipes) {
      if (plannedRecipes.isEmpty) return Text(str.noRecipesYetMessage);

      return Column(children: [
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(str.numberOfMeals(plannedRecipes.length.toString())),
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll<Color>(MyColors.terracotta),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Créer liste des courses',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: Week.values.map((day) {
                final planned = plannedRecipes
                    .where((recipe) => recipe.schedule == day)
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        day.localizedName(context),
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    planned.isEmpty
                        ? const Text('No recipe scheduled this day')
                        : ScheduledRecipesList(recipes: planned),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ]);
    }

    return MyNavigator(
      title: str.myMenu,
      page: plannedAsync.when(
        data: buildMenu,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class ScheduledRecipesList extends ConsumerWidget {
  const ScheduledRecipesList({super.key, required this.recipes});
  final List<PlannedRecipe> recipes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final str = context.l;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Dismissible(
          key: ValueKey(recipe.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            final hid = ref.read(currentHouseholdIdProvider).value;
            if (hid == null) return;
            await ref
                .read(plannedRecipesRepositoryProvider)
                .deletePlannedRecipe(hid, recipe.id);
          },
          background: Container(),
          secondaryBackground: Container(
            color: MyColors.dismissibleUnschedule,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(str.unplanned,
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                const Icon(Icons.event_busy, color: Colors.black),
              ],
            ),
          ),
          child: PlannedRecipeTile(plannedRecipe: recipe),
        );
      },
    );
  }
}
