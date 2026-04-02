import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/l10n/app_localizations.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/models/ingredient.dart';
import 'package:myhome/src/models/ingredients.dart';

class IngredientsForm extends HookConsumerWidget {
  final _ingredientFormKey = GlobalKey<FormState>();
  final ingredients = useState<Ingredients>(const Ingredients([]));
  final invalidInput = useState<bool>(false);

  final Color onInvalidInputColor = const Color.fromARGB(255, 234, 2, 2);
  late final ScaffoldMessengerState snackBar;
  late final AppLocalizations str;

  IngredientsForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantityController = useTextEditingController();
    final ingredientController = useTextEditingController();
    final scrollController = ScrollController();

    snackBar = ScaffoldMessenger.of(context);
    str = context.l;

    void addIngredients(Ingredients newIngredients) {
      ingredients.value += newIngredients;
    }

    useEffect(() {
      return () {
        quantityController.dispose();
        ingredientController.dispose();
      };
    }, []);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(str.ingredients),
          Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ingredientInputWidget(
                    ingredientController, quantityController, addIngredients),
                _ingredientsView(scrollController, ingredients.value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingredientsView(
      ScrollController scrollController, Ingredients ingredients) {
    final ingredientsController = useTextEditingController();

    useEffect(() {
      ingredientsController.text = ingredients.formattingToString();
      return null;
    }, [ingredients]);

    return Scrollbar(
      scrollbarOrientation: ScrollbarOrientation.bottom,
      controller: scrollController,
      thumbVisibility: true,
      child: TextField(
        scrollController: scrollController,
        readOnly: true,
        controller: ingredientsController,
        decoration: const InputDecoration(
            border: InputBorder.none, contentPadding: EdgeInsets.all(8.0)),
        maxLines: 5,
      ),
    );
  }

  Widget _ingredientInputWidget(
    TextEditingController ingredientController,
    TextEditingController quantityController,
    Function addIngredients,
  ) {
    return Form(
      key: _ingredientFormKey,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: invalidInput.value ? onInvalidInputColor : Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: ingredientController,
                decoration: _ingredientTextFieldDecoration(str.ingredient),
              ),
            ),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: quantityController,
                decoration: _ingredientTextFieldDecoration(str.quantity),
              ),
            ),
            IconButton.outlined(
              onPressed: () => _validateIngredientEntry(
                ingredientController,
                quantityController,
                addIngredients,
              ),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void _validateIngredientEntry(
    TextEditingController ingredientController,
    TextEditingController quantityController,
    Function addIngredients,
  ) async {
    final ingredientName = ingredientController.text;
    if (ingredientName.isEmpty) {
      snackBar.showSnackBar(SnackBar(
        backgroundColor: onInvalidInputColor,
        content: Text(str.emptyIngredientMessage),
      ));
      invalidInput.value = true;
      await Future.delayed(const Duration(seconds: 1));
      invalidInput.value = false;
    } else {
      final ingredient =
          Ingredient(name: ingredientName, quantity: quantityController.text);
      addIngredients(Ingredients([ingredient]));
      ingredientController.clear();
      quantityController.clear();
    }
  }
}

InputDecoration _ingredientTextFieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
  );
}
