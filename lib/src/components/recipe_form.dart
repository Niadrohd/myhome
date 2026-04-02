import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/l10n/app_localizations.dart';
import 'package:myhome/routes/named_routes.dart';
import 'package:myhome/src/components/ingredients_form.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/models/ingredients.dart';
import 'package:myhome/src/providers/household_providers.dart';
import 'package:myhome/src/providers/recipes_provider.dart';

class CreateRecipeForm extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  late AppLocalizations str;

  CreateRecipeForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final cookingTimeController = useTextEditingController();
    final preparationTimeController = useTextEditingController();
    final linkController = useTextEditingController();

    final ingredientsForm = IngredientsForm();

    str = context.l;

    useEffect(() {
      return () {
        nameController.dispose();
        preparationTimeController.dispose();
        cookingTimeController.dispose();
        linkController.dispose();
      };
    }, []);

    void handleAddRecipe() async {
      if (_formKey.currentState!.validate()) {
        final hid = ref.read(currentHouseholdIdProvider).value;
        if (hid == null) return;
        await ref.read(recipesRepositoryProvider).addRecipe(
              hid,
              name: nameController.text,
              preparationTime:
                  int.tryParse(preparationTimeController.text) ?? 0,
              cookingTime: int.tryParse(cookingTimeController.text) ?? 0,
              link: linkController.text,
              ingredients: Ingredients(
                  ingredientsForm.ingredients.value.ingredientsList),
            );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(str.savedRecipeMessage(nameController.text))));
        Navigator.pushReplacementNamed(context, RoutesName.recipesList.path);
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _titledRecipeTextField(str.recipeName, nameController),
          _titledRecipeTextField(
              str.preparationTime('(mins)'), preparationTimeController,
              validate: false),
          _titledRecipeTextField(
              str.cookingTime('(mins)'), cookingTimeController,
              validate: false),
          _titledRecipeTextField(str.recipeLink, linkController,
              validate: false),
          ingredientsForm,
          const SizedBox(height: 20.0),
          ElevatedButton(onPressed: handleAddRecipe, child: Text(str.save)),
        ],
      ),
    );
  }

  Widget _titledRecipeTextField(
    String title,
    TextEditingController controller, {
    bool validate = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          TextFormField(
            validator: (newValue) {
              if (validate && (newValue == null || newValue.isEmpty)) {
                return str.invalidInputMessage;
              }
              return null;
            },
            controller: controller,
            decoration: InputDecoration(
              focusColor: const Color.fromARGB(255, 2, 199, 243),
              border: const OutlineInputBorder(),
              hintText: title,
            ),
          ),
        ],
      ),
    );
  }
}
