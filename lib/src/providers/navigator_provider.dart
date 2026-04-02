import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myhome/routes/named_routes.dart';

class NavigatorNotifier extends StateNotifier<RoutesName> {
  NavigatorNotifier() : super(RoutesName.recipesList);

  void changeRoute(RoutesName newRoute) {
    state = newRoute;
  }
}

final navigatorProvider =
    StateNotifierProvider<NavigatorNotifier, RoutesName>(
  (ref) => NavigatorNotifier(),
);
