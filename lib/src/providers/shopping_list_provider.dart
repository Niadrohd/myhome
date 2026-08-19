import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myhome/src/providers/planned_recipes_provider.dart';
import 'package:myhome/src/providers/recipes_provider.dart';
import 'package:myhome/src/utils/shopping_list_calculator.dart';

final shoppingListProvider = Provider<AsyncValue<List<ShoppingListEntry>>>(
  (ref) {
    final plannedAsync = ref.watch(plannedRecipesProvider);
    final recipesAsync = ref.watch(recipesProvider);

    if (plannedAsync.hasError) {
      return AsyncValue.error(
          plannedAsync.error!, plannedAsync.stackTrace ?? StackTrace.empty);
    }
    if (recipesAsync.hasError) {
      return AsyncValue.error(
          recipesAsync.error!, recipesAsync.stackTrace ?? StackTrace.empty);
    }
    if (!plannedAsync.hasValue || !recipesAsync.hasValue) {
      return const AsyncValue.loading();
    }

    return AsyncValue.data(calculateShoppingList(
      plannedRecipes: plannedAsync.value!,
      recipes: recipesAsync.value!,
    ));
  },
);
