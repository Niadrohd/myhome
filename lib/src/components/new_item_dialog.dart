import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/src/extensions/translations.dart';
import 'package:myhome/src/providers/items_provider.dart';

class NewItemDialog extends HookConsumerWidget {
  NewItemDialog({super.key, required this.hid});
  final _formKey = GlobalKey<FormState>();
  final String hid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(itemsRepositoryProvider);
    final nameController = useTextEditingController();
    final detailsController = useTextEditingController();
    final quantityController = useTextEditingController(text: '1');
    final unitController = useTextEditingController(text: 'pcs');

    final str = context.l;

    void handleAddNewItem() {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      repo.addItem(
        hid,
        name: nameController.text,
        quantity: int.parse(quantityController.text),
        details: detailsController.text,
        unit: unitController.text,
      );
      Navigator.of(context).pop();
    }

    return AlertDialog(
      title: Text(str.addNewItemTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _titledItemTextField(str.itemNameLabel, nameController),
              _titledItemTextField(str.itemDetailsLabel, detailsController,
                  validate: false),
              _titledItemTextField(
                  str.itemQuantityLabel, quantityController),
              _titledItemTextField(str.itemUnitLabel, unitController,
                  isNextAction: false),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(str.cancelButtonLabel),
        ),
        ElevatedButton(
          onPressed: handleAddNewItem,
          child: Text(str.saveButtonLabel),
        ),
      ],
    );
  }

  Widget _titledItemTextField(
    String title,
    TextEditingController controller, {
    bool validate = true,
    bool isNextAction = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          TextFormField(
            textInputAction: isNextAction
                ? TextInputAction.next
                : TextInputAction.done,
            validator: (newValue) {
              if (validate &&
                  (newValue == null || newValue.isEmpty)) {
                return 'Invalid input';
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
