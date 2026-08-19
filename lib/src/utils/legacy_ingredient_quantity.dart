import 'package:myhome/src/utils/unit.dart';

/// Parses the old free-text ingredient quantity format (e.g. "200g", "1.5L")
/// stored before ingredients had a structured quantity + unit. Used only as a
/// fallback when reading Firestore documents saved before that change.
class LegacyIngredientQuantity {
  static final _pattern = RegExp(
    r'^\s*([0-9]+(?:[.,][0-9]+)?)\s*(kg|g|ml|cl|l)?\s*$',
    caseSensitive: false,
  );

  static (double?, Unit) parse(String raw) {
    final match = _pattern.firstMatch(raw);
    if (match == null) return (null, Unit.none);
    final quantity = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (quantity == null) return (null, Unit.none);
    return (quantity, _unitFromSuffix(match.group(2)));
  }

  static Unit _unitFromSuffix(String? suffix) {
    switch (suffix?.toLowerCase()) {
      case 'kg':
        return Unit.kg;
      case 'g':
        return Unit.g;
      case 'ml':
        return Unit.mL;
      case 'cl':
        return Unit.cL;
      case 'l':
        return Unit.L;
      default:
        return Unit.none;
    }
  }
}
