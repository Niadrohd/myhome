import 'package:flutter_test/flutter_test.dart';
import 'package:myhome/src/utils/legacy_ingredient_quantity.dart';
import 'package:myhome/src/utils/unit.dart';

void main() {
  test('parses a plain gram quantity', () {
    final (quantity, unit) = LegacyIngredientQuantity.parse('200g');
    expect(quantity, 200);
    expect(unit, Unit.g);
  });

  test('parses a decimal liter quantity', () {
    final (quantity, unit) = LegacyIngredientQuantity.parse('1.5L');
    expect(quantity, 1.5);
    expect(unit, Unit.L);
  });

  test('parses kilograms distinctly from grams', () {
    final (quantity, unit) = LegacyIngredientQuantity.parse('2kg');
    expect(quantity, 2);
    expect(unit, Unit.kg);
  });

  test('parses a bare number with no unit', () {
    final (quantity, unit) = LegacyIngredientQuantity.parse('3');
    expect(quantity, 3);
    expect(unit, Unit.none);
  });

  test('falls back to null/none for unparseable text', () {
    final (quantity, unit) = LegacyIngredientQuantity.parse('a pinch');
    expect(quantity, isNull);
    expect(unit, Unit.none);
  });
}
