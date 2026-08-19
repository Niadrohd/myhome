import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/l10n/app_localizations.dart';
import 'package:myhome/routes/named_routes.dart';
import 'package:myhome/src/components/ingredients_form.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/models/ingredients.dart';
import 'package:myhome/src/models/recipe.dart';
import 'package:myhome/src/providers/household_providers.dart';
import 'package:myhome/src/providers/recipes_provider.dart';

class CreateRecipeForm extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  late AppLocalizations str;

  /// When provided, the form edits this recipe instead of creating a new one.
  final Recipe? recipe;

  CreateRecipeForm({super.key, this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: recipe?.name);
    final cookingTimeController =
        useTextEditingController(text: recipe?.cookingTime.toString());
    final preparationTimeController =
        useTextEditingController(text: recipe?.preparationTime.toString());
    final linkController = useTextEditingController(text: recipe?.link);
    final portions = useState(recipe?.portions ?? 2);

    final ingredientsForm =
        IngredientsForm(initialIngredients: recipe?.ingredients);

    str = context.l;

    useEffect(() {
      return () {
        nameController.dispose();
        preparationTimeController.dispose();
        cookingTimeController.dispose();
        linkController.dispose();
      };
    }, []);

    void handleSaveRecipe() async {
      if (_formKey.currentState!.validate()) {
        final hid = ref.read(currentHouseholdIdProvider).value;
        if (hid == null) return;
        final repo = ref.read(recipesRepositoryProvider);
        final ingredients =
            Ingredients(ingredientsForm.ingredients.value.ingredientsList);
        final preparationTime =
            int.tryParse(preparationTimeController.text) ?? 0;
        final cookingTime = int.tryParse(cookingTimeController.text) ?? 0;

        if (recipe == null) {
          await repo.addRecipe(
            hid,
            name: nameController.text,
            preparationTime: preparationTime,
            cookingTime: cookingTime,
            link: linkController.text,
            ingredients: ingredients,
            portions: portions.value,
          );
        } else {
          await repo.updateRecipe(
            hid,
            recipe!.id,
            name: nameController.text,
            preparationTime: preparationTime,
            cookingTime: cookingTime,
            link: linkController.text,
            ingredients: ingredients,
            portions: portions.value,
          );
        }
        if (!context.mounted) return;
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
          _portionsCounter(portions),
          ingredientsForm,
          const SizedBox(height: 20.0),
          ElevatedButton(onPressed: handleSaveRecipe, child: Text(str.save)),
        ],
      ),
    );
  }

  Widget _portionsCounter(ValueNotifier<int> portions) {
    const minValue = 1;
    const maxValue = 50;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(child: Text(str.portions)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: portions.value <= minValue
                ? null
                : () => portions.value--,
          ),
          Text(
            '${portions.value}',
            style: const TextStyle(fontSize: 18.0),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: portions.value >= maxValue
                ? null
                : () => portions.value++,
          ),
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
