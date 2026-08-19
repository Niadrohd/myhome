import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/l10n/app_localizations.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/models/ingredient.dart';
import 'package:myhome/src/models/ingredients.dart';
import 'package:myhome/src/utils/unit.dart';

class IngredientsForm extends HookConsumerWidget {
  final _ingredientFormKey = GlobalKey<FormState>();
  final ValueNotifier<Ingredients> ingredients;
  final ValueNotifier<bool> invalidInput;

  final Color onInvalidInputColor = const Color.fromARGB(255, 234, 2, 2);
  late final ScaffoldMessengerState snackBar;
  late final AppLocalizations str;

  // Hooks are kept in the same order as the original field initializers
  // (ingredients then invalidInput) so flutter_hooks stays consistent.
  IngredientsForm({super.key, Ingredients? initialIngredients})
      : ingredients = useState(initialIngredients ?? const Ingredients([])),
        invalidInput = useState<bool>(false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantityController = useTextEditingController();
    final ingredientController = useTextEditingController();
    final selectedUnit = useState<Unit>(Unit.none);

    snackBar = ScaffoldMessenger.of(context);
    str = context.l;

    void addIngredients(Ingredients newIngredients) {
      ingredients.value += newIngredients;
    }

    void removeIngredientAt(int index) {
      final list = [...ingredients.value.ingredientsList];
      list.removeAt(index);
      ingredients.value = Ingredients(list);
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
                _ingredientInputWidget(ingredientController,
                    quantityController, selectedUnit, addIngredients),
                _ingredientsView(ingredients.value, removeIngredientAt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingredientsView(
    Ingredients ingredients,
    void Function(int index) onRemoveAt,
  ) {
    final list = ingredients.ingredientsList;
    if (list.isEmpty) return const SizedBox(height: 8.0);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: [
          for (var i = 0; i < list.length; i++)
            Chip(
              label: Text(_formatIngredient(list[i])),
              deleteIcon: const Icon(Icons.close, size: 18.0),
              onDeleted: () => onRemoveAt(i),
            ),
        ],
      ),
    );
  }

  String _formatIngredient(Ingredient ingredient) {
    final quantity = ingredient.quantity;
    if (quantity == null || ingredient.unit == Unit.none) {
      return ingredient.name;
    }
    return '${ingredient.name}: $quantity ${ingredient.unit.shortLabel}';
  }

  Widget _ingredientInputWidget(
    TextEditingController ingredientController,
    TextEditingController quantityController,
    ValueNotifier<Unit> selectedUnit,
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
              flex: 3,
              child: TextFormField(
                controller: ingredientController,
                decoration: _ingredientTextFieldDecoration(str.ingredient),
              ),
            ),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _ingredientTextFieldDecoration(str.quantity),
              ),
            ),
            _unitPicker(selectedUnit),
            IconButton.outlined(
              onPressed: () => _validateIngredientEntry(
                ingredientController,
                quantityController,
                selectedUnit,
                addIngredients,
              ),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitPicker(ValueNotifier<Unit> selectedUnit) {
    return PopupMenuButton<Unit>(
      initialValue: selectedUnit.value,
      onSelected: (unit) => selectedUnit.value = unit,
      itemBuilder: (context) => Unit.values
          .map((unit) => PopupMenuItem(
                value: unit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(unit.localizedName(context)),
                    if (unit == selectedUnit.value) const Icon(Icons.check),
                  ],
                ),
              ))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedUnit.value == Unit.none
                ? str.unitNone
                : selectedUnit.value.shortLabel),
            const Icon(Icons.unfold_more_outlined, size: 16),
          ],
        ),
      ),
    );
  }

  void _validateIngredientEntry(
    TextEditingController ingredientController,
    TextEditingController quantityController,
    ValueNotifier<Unit> selectedUnit,
    Function addIngredients,
  ) async {
    final ingredientName = ingredientController.text;
    final unit = selectedUnit.value;
    final quantityText = quantityController.text.trim().replaceAll(',', '.');
    final quantity = double.tryParse(quantityText);
    final hasInvalidQuantity = unit != Unit.none && quantity == null;

    if (ingredientName.isEmpty || hasInvalidQuantity) {
      snackBar.showSnackBar(SnackBar(
        backgroundColor: onInvalidInputColor,
        content: Text(ingredientName.isEmpty
            ? str.emptyIngredientMessage
            : str.invalidInputMessage),
      ));
      invalidInput.value = true;
      await Future.delayed(const Duration(seconds: 1));
      invalidInput.value = false;
    } else {
      final ingredient = Ingredient(
        name: ingredientName,
        quantity: unit == Unit.none ? null : quantity,
        unit: unit,
      );
      addIngredients(Ingredients([ingredient]));
      ingredientController.clear();
      quantityController.clear();
      selectedUnit.value = Unit.none;
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
