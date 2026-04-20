import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myhome/src/models/planned_recipe.dart';
import 'package:myhome/src/repositories/planned_recipes_repository.dart';

import 'firebase_providers.dart';
import 'household_providers.dart';

final plannedRecipesRepositoryProvider =
    Provider<PlannedRecipesRepository>((ref) {
  return PlannedRecipesRepository(ref.watch(firestoreProvider));
});

final plannedRecipesProvider = StreamProvider<List<PlannedRecipe>>((ref) {
  final hidAsync = ref.watch(currentHouseholdIdProvider);
  final repo = ref.watch(plannedRecipesRepositoryProvider);

  return hidAsync.when(
    data: (hid) =>
        hid == null ? const Stream.empty() : repo.watchPlannedRecipes(hid),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final isRecipePlannedProvider =
    FutureProvider.family<bool, String>((ref, recipeId) async {
  final plannedRecipesAsync = await ref.watch(plannedRecipesProvider.future);
  return plannedRecipesAsync.any((planned) => planned.recipeId == recipeId);
});
