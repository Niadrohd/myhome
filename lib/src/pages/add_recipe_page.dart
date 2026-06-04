import 'package:flutter/material.dart';
import 'package:myhome/src/components/recipe_form.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/models/recipe.dart';
import 'package:myhome/src/my_navigator.dart';

class AddRecipePage extends StatelessWidget {
  const AddRecipePage({super.key, this.recipe});

  /// When provided, the form edits this recipe instead of creating a new one.
  final Recipe? recipe;

  @override
  Widget build(BuildContext context) {
    return MyNavigator(
      title: recipe?.name ?? context.l.newRecipe,
      page: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [CreateRecipeForm(recipe: recipe)],
          ),
        ),
      ),
    );
  }
}
