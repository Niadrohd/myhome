import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myhome/routes/named_routes.dart';
import 'package:myhome/src/pages/add_recipe_page.dart';
import 'package:myhome/src/pages/auth_gate.dart';
import 'package:myhome/src/pages/menu_page.dart';
import 'package:myhome/src/pages/recipe_details_page.dart';
import 'package:myhome/src/pages/recipes_list_page.dart';
import 'package:myhome/src/pages/stock_page.dart';
import 'package:myhome/src/pages/todo_lists_page.dart';
import 'package:myhome/src/pages/todo_list_details_page.dart';
import 'package:myhome/theme/colors.dart';

import 'l10n/app_localizations.dart';

class MyHomeApp extends StatelessWidget {
  const MyHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    PageRouteBuilder customPageRoute(Widget page) {
      return PageRouteBuilder(pageBuilder: (_, __, ___) => page);
    }

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: MyColors.turquoise),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: EasyDynamicTheme.of(context).themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        if (settings.name == RoutesName.recipesList.path) {
          return customPageRoute(const RecipesListPage());
        } else if (settings.name == RoutesName.createRecipe.path) {
          return customPageRoute(const AddRecipePage());
        } else if (settings.name == RoutesName.menu.path) {
          return customPageRoute(const MenuPage());
        } else if (settings.name == RoutesName.recipeDetails.path) {
          final args = settings.arguments as Map<String, dynamic>;
          return customPageRoute(RecipeDetailsPage(recipe: args['recipe']));
        } else if (settings.name == RoutesName.stock.path) {
          return customPageRoute(const StockPage());
        } else if (settings.name == RoutesName.todoLists.path) {
          return customPageRoute(const TodoListsPage());
        } else if (settings.name == '/todo_list_details') {
          final args = settings.arguments as Map<String, dynamic>;
          return customPageRoute(
            TodoListDetailsPage(listId: args['listId'] as String),
          );
        }
        return customPageRoute(const AuthGate());
      },
    );
  }
}
