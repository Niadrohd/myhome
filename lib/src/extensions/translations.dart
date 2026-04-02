import 'package:flutter/material.dart';
import 'package:myhome/l10n/app_localizations.dart';

extension ContextLocalizationExtension on BuildContext {
  AppLocalizations get l {
    return AppLocalizations.of(this)!;
  }
}
