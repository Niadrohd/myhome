import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myhome/src/models/planned_recipe.dart';
import 'package:myhome/src/models/recipe.dart';
import 'package:myhome/src/utils/week.dart';

class PlannedRecipesRepository {
  PlannedRecipesRepository(this._fs);
  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> _plannedRef(String householdId) =>
      _fs
          .collection('households')
          .doc(householdId)
          .collection('planned_recipes');

  Stream<List<PlannedRecipe>> watchPlannedRecipes(String householdId) {
    return _plannedRef(householdId).snapshots().map(
          (snapshot) => snapshot.docs.map(_fromDoc).toList(),
        );
  }

  Future<void> addPlannedRecipe(
    String householdId, {
    required Recipe recipe,
    int quantity = 2,
    Week schedule = Week.other,
  }) {
    return _plannedRef(householdId).add({
      'recipe_id': recipe.id,
      'quantity': quantity,
      'schedule': schedule.name,
    });
  }

  Future<void> deletePlannedRecipe(String householdId, String plannedRecipeId) {
    return _plannedRef(householdId).doc(plannedRecipeId).delete();
  }

  Future<void> deleteByRecipe(String householdId, String recipeId) async {
    final docs = await _plannedRef(householdId)
        .where('recipe_id', isEqualTo: recipeId)
        .get();
    for (final doc in docs.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> switchRecipe(
    String householdId,
    Recipe recipe,
    List<PlannedRecipe> currentPlanned,
  ) async {
    final existing =
        currentPlanned.where((pr) => pr.recipeId == recipe.id).firstOrNull;
    if (existing == null) {
      await addPlannedRecipe(householdId, recipe: recipe);
    } else {
      await deletePlannedRecipe(householdId, existing.id);
    }
  }

  Future<void> scheduleRecipe(
    String householdId,
    String plannedRecipeId,
    Week day,
  ) {
    return _plannedRef(householdId)
        .doc(plannedRecipeId)
        .update({'schedule': day.name});
  }

  Future<void> changeRecipeQuantity(
    String householdId,
    String plannedRecipeId,
    int quantity,
  ) {
    return _plannedRef(householdId)
        .doc(plannedRecipeId)
        .update({'quantity': quantity});
  }

  PlannedRecipe _fromDoc(
    DocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final data = d.data()!;
    final recipeId = (data['recipe_id'] as String?) ??
        (data['recipe'] as Map<String, dynamic>?)?['id'] ??
        '';
    final scheduleStr = (data['schedule'] as String?) ?? 'other';
    final schedule = Week.values.firstWhere(
      (w) => w.name == scheduleStr,
      orElse: () => Week.other,
    );
    return PlannedRecipe(
      id: d.id,
      recipeId: recipeId,
      quantity: (data['quantity'] as num?)?.toInt() ?? 2,
      schedule: schedule,
    );
  }
}
