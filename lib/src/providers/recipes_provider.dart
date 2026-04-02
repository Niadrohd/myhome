import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myhome/src/models/recipe.dart';
import 'package:myhome/src/repositories/recipes_repository.dart';
import 'firebase_providers.dart';
import 'household_providers.dart';

final recipesRepositoryProvider = Provider<RecipesRepository>((ref) {
  return RecipesRepository(ref.watch(firestoreProvider));
});

final recipesProvider = StreamProvider<List<Recipe>>((ref) {
  final hidAsync = ref.watch(currentHouseholdIdProvider);
  final repo = ref.watch(recipesRepositoryProvider);

  return hidAsync.when(
    data: (hid) =>
        hid == null ? const Stream.empty() : repo.watchRecipes(hid),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});
