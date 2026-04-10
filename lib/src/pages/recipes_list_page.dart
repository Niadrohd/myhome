import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/routes/named_routes.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/models/recipe.dart';
import 'package:myhome/src/components/add_fab.dart';
import 'package:myhome/src/my_navigator.dart';
import 'package:myhome/src/providers/household_providers.dart';
import 'package:myhome/src/providers/planned_recipes_provider.dart';
import 'package:myhome/src/providers/recipes_provider.dart';
import 'package:myhome/src/utils.dart';
import 'package:myhome/theme/colors.dart';

class RecipesListPage extends HookConsumerWidget {
  const RecipesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);
    final plannedAsync = ref.watch(plannedRecipesProvider);
    final str = context.l;

    Widget buildList(List<Recipe> recipes) {
      if (recipes.isEmpty) return Text(str.noRecipesYetMessage);

      return ListView.builder(
        itemCount: recipes.length,
        prototypeItem: const Dismissible(
          key: Key(''),
          child: ListTile(
            leading: CircleAvatar(),
            title: Text(''),
            subtitle: Text(''),
          ),
        ),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          final planned = plannedAsync.value ?? [];
          final isFavorite =
              planned.where((fav) => fav.recipeId == recipe.id).isNotEmpty;

          return Dismissible(
            key: ValueKey(recipe.id),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              final hid = ref.read(currentHouseholdIdProvider).value;
              if (hid == null) return;
              await ref
                  .read(recipesRepositoryProvider)
                  .deleteRecipe(hid, recipe.id);
              await ref
                  .read(plannedRecipesRepositoryProvider)
                  .deleteByRecipe(hid, recipe.id);
            },
            background: Container(),
            secondaryBackground: Container(
              color: MyColors.dismissibleDeleteColor,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(str.delete,
                      style:
                          const TextStyle(fontSize: 18, color: Colors.white)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                  const Icon(Icons.delete, color: Colors.white),
                ],
              ),
            ),
            child: ListTile(
              title: Text(recipe.name.capitalize()),
              subtitle: Text(
                  'Time: ${recipe.preparationTime} + ${recipe.cookingTime} min'),
              leading: const CircleAvatar(
                foregroundImage: AssetImage('assets/images/repas_img.jpg'),
              ),
              trailing: IconButton(
                icon: isFavorite
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_border),
                onPressed: () async {
                  final hid = ref.read(currentHouseholdIdProvider).value;
                  if (hid == null) return;
                  await ref
                      .read(plannedRecipesRepositoryProvider)
                      .switchRecipe(hid, recipe, planned);
                },
              ),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  RoutesName.recipeDetails.path,
                  arguments: <String, Recipe>{'recipe': recipe},
                );
              },
            ),
          );
        },
      );
    }

    return MyNavigator(
      title: str.myRecipes,
      page: Stack(
        children: [
          recipesAsync.when(
            data: buildList,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur: $e')),
          ),
          AddFab(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                RoutesName.createRecipe.path,
              );
            },
          ),
        ],
      ),
    );
  }
}
