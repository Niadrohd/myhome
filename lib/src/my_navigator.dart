import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myhome/routes/named_routes.dart';
import 'package:myhome/src/providers/navigator_provider.dart';
import 'package:myhome/theme/colors.dart';

class MyNavigator extends ConsumerWidget {
  const MyNavigator({
    super.key,
    required this.title,
    required this.page,
    this.showCentralButton = true,
  });

  final Widget page;
  final String title;
  final bool showCentralButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        backgroundColor: MyColors.turquoise,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: page),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: MyColors.turquoise,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NavigatorIcon(
              routeName: RoutesName.recipesList,
              iconData: Icons.restaurant_menu,
              ref: ref,
            ),
            NavigatorIcon(
              routeName: RoutesName.menu,
              iconData: Icons.calendar_month_outlined,
              ref: ref,
            ),
            NavigatorIcon(
              routeName: RoutesName.stock,
              iconData: Icons.inventory_2_outlined,
              ref: ref,
            ),
          ],
        ),
      ),
      floatingActionButton: showCentralButton
          ? FloatingActionButton.large(
              shape: const CircleBorder(),
              backgroundColor: MyColors.terracotta,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  RoutesName.createRecipe.path,
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class NavigatorIcon extends StatelessWidget {
  const NavigatorIcon({
    super.key,
    required this.routeName,
    required this.iconData,
    required this.ref,
  });

  final RoutesName routeName;
  final IconData iconData;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final RoutesName actualRoute = ref.watch(navigatorProvider);
    return IconButton(
      onPressed: () {
        ref.read(navigatorProvider.notifier).changeRoute(routeName);
        Navigator.pushReplacementNamed(context, routeName.path);
      },
      icon: Icon(
        iconData,
        size: 28,
        color: actualRoute == routeName ? MyColors.activeColor : MyColors.inactiveColor,
      ),
    );
  }
}
