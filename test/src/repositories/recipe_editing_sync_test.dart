import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myhome/src/models/ingredients.dart';
import 'package:myhome/src/repositories/planned_recipes_repository.dart';
import 'package:myhome/src/repositories/recipes_repository.dart';
import 'package:myhome/src/utils/week.dart';

void main() {
  const householdId = 'household-1';

  test(
      'editing a recipe updates its fields but leaves planned quantities untouched',
      () async {
    final firestore = FakeFirebaseFirestore();
    final recipesRepo = RecipesRepository(firestore);
    final plannedRepo = PlannedRecipesRepository(firestore);

    await recipesRepo.addRecipe(
      householdId,
      name: 'Pasta',
      preparationTime: 10,
      cookingTime: 20,
      link: 'https://example.com',
      ingredients: const Ingredients([]),
      portions: 2,
    );
    final recipe = (await recipesRepo.watchRecipes(householdId).first).single;

    // The user planned this recipe and explicitly bumped the quantity away
    // from the recipe's default portions.
    await plannedRepo.addPlannedRecipe(
      householdId,
      recipeId: recipe.id,
      quantity: 6,
      schedule: Week.monday,
    );
    final planned =
        (await plannedRepo.watchPlannedRecipes(householdId).first).single;
    expect(planned.quantity, 6);

    await recipesRepo.updateRecipe(
      householdId,
      recipe.id,
      name: 'Pasta Bolognese',
      preparationTime: 15,
      cookingTime: 25,
      link: 'https://example.com',
      ingredients: const Ingredients([]),
      portions: 4,
    );

    final updatedRecipe =
        (await recipesRepo.watchRecipes(householdId).first).single;
    expect(updatedRecipe.name, 'Pasta bolognese');
    expect(updatedRecipe.portions, 4);

    final updatedPlanned =
        (await plannedRepo.watchPlannedRecipes(householdId).first).single;
    expect(updatedPlanned.quantity, 6);
    expect(updatedPlanned.schedule, Week.monday);
  });
}
