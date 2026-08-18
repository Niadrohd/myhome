import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
    final str = context.l;
    final searchController = useTextEditingController();
    final query = useState('');

    Widget buildList(List<Recipe> recipes) {
      return ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          final isFavoriteAsync = ref.watch(isRecipePlannedProvider(recipe.id));

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
                  Flexible(
                    child: Text(
                      str.delete,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                  const Icon(Icons.delete, color: Colors.white),
                ],
              ),
            ),
            child: ListTile(
              title: Text(
                recipe.name.capitalize(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              subtitle: Text(
                'Time: ${recipe.preparationTime} + ${recipe.cookingTime} min',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              leading: const CircleAvatar(
                foregroundImage: AssetImage('assets/images/repas_img.jpg'),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        RoutesName.createRecipe.path,
                        arguments: <String, Recipe>{'recipe': recipe},
                      );
                    },
                  ),
                  IconButton(
                    icon: isFavoriteAsync.maybeWhen(
                      data: (isFav) => isFav
                          ? const Icon(Icons.favorite)
                          : const Icon(Icons.favorite_border),
                      orElse: () => const Icon(Icons.favorite_border),
                    ),
                    onPressed: () async {
                      final hid = ref.read(currentHouseholdIdProvider).value;
                      if (hid == null) return;
                      await ref
                          .read(plannedRecipesRepositoryProvider)
                          .switchRecipe(hid, recipe.id,
                              portions: recipe.portions);
                    },
                  ),
                ],
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => query.value = value,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: '${str.search}...',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: query.value.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: str.delete,
                            onPressed: () {
                              searchController.clear();
                              query.value = '';
                            },
                          ),
                  ),
                ),
              ),
              Expanded(
                child: recipesAsync.when(
                  data: (recipes) {
                    if (recipes.isEmpty) {
                      return Center(child: Text(str.noRecipesYetMessage));
                    }
                    final q = query.value.trim().toLowerCase();
                    final filtered = q.isEmpty
                        ? recipes
                        : recipes
                            .where((r) =>
                                r.name.toLowerCase().contains(q) ||
                                r.ingredients
                                    .getNames()
                                    .any((n) => n.toLowerCase().contains(q)))
                            .toList();
                    if (filtered.isEmpty) {
                      return Center(child: Text(str.noRecipesYetMessage));
                    }
                    return buildList(filtered);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erreur: $e')),
                ),
              ),
            ],
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
