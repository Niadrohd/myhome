import 'package:flutter/widgets.dart';
import 'package:myhome/l10n/app_localizations.dart';
import 'package:myhome/src/extensions/translations.dart';

enum Unit {
  none,
  piece,
  g,
  kg,
  mL,
  cL,
  L,
  tablespoon,
  teaspoon,
  pinch,
}

extension UnitExtensions on Unit {
  String localizedName(BuildContext context) {
    AppLocalizations str = context.l;
    switch (this) {
      case Unit.none:
        return str.unitNone;
      case Unit.piece:
        return str.unitPiece;
      case Unit.g:
        return str.unitGram;
      case Unit.kg:
        return str.unitKilogram;
      case Unit.mL:
        return str.unitMilliliter;
      case Unit.cL:
        return str.unitCentiliter;
      case Unit.L:
        return str.unitLiter;
      case Unit.tablespoon:
        return str.unitTablespoon;
      case Unit.teaspoon:
        return str.unitTeaspoon;
      case Unit.pinch:
        return str.unitPinch;
    }
  }

  String get shortLabel {
    switch (this) {
      case Unit.none:
        return '';
      case Unit.piece:
        return 'pcs';
      case Unit.g:
        return 'g';
      case Unit.kg:
        return 'kg';
      case Unit.mL:
        return 'mL';
      case Unit.cL:
        return 'cL';
      case Unit.L:
        return 'L';
      case Unit.tablespoon:
        return 'cs';
      case Unit.teaspoon:
        return 'cc';
      case Unit.pinch:
        return 'pinch';
    }
  }
}
