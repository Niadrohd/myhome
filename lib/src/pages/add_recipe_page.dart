import 'package:flutter/material.dart';
import 'package:myhome/src/components/recipe_form.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/my_navigator.dart';

class AddRecipePage extends StatelessWidget {
  const AddRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyNavigator(
      title: context.l.newRecipe,
      page: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [CreateRecipeForm()],
          ),
        ),
      ),
      showCentralButton: false,
    );
  }
}
