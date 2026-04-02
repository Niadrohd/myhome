import 'package:flutter/widgets.dart';
import 'package:myhome/l10n/app_localizations.dart';
import 'package:myhome/src/extensions/translations.dart';

enum Week {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
  other
}

extension WeekExtensions on Week {
  String localizedName(BuildContext context) {
    AppLocalizations str = context.l;
    switch (this) {
      case Week.monday:
        return str.monday;
      case Week.tuesday:
        return str.tuesday;
      case Week.wednesday:
        return str.wednesday;
      case Week.thursday:
        return str.thursday;
      case Week.friday:
        return str.friday;
      case Week.saturday:
        return str.saturday;
      case Week.sunday:
        return str.sunday;
      case Week.other:
        return str.unscheduled;
    }
  }
}
