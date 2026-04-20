import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/src/models/recipe.dart';
import 'package:myhome/src/my_navigator.dart';
import 'package:myhome/theme/colors.dart';
import 'package:myhome/theme/dimensions.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailsPage extends ConsumerWidget {
  const RecipeDetailsPage({super.key, required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MyNavigator(
      title: recipe.name,
      page: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(defaultSymmetricPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preparation Time: ${recipe.preparationTime} minutes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: defaultTallVerticalPadding),
              Text(
                'Cooking Time: ${recipe.cookingTime} minutes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: defaultTallVerticalPadding),
              Text('Link:',
                  style: Theme.of(context).textTheme.headlineSmall),
              InkWell(
                child: Text(
                  recipe.link,
                  style: const TextStyle(
                    color: MyColors.linkedColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () => launchUrl(Uri.parse(recipe.link)),
              ),
              const SizedBox(height: defaultTallVerticalPadding),
              Text('Ingredients:',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text(recipe.ingredients.formattingToString()),
              const SizedBox(height: defaultTallVerticalPadding),
            ],
          ),
        ),
      ),
    );
  }
}
