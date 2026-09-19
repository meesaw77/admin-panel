import 'package:admin/components/smooth_scroll_wrapper.dart';
import 'package:admin/controllers/navigation_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/components/header.dart';
import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navigationController, child) {
        return Scaffold(
          backgroundColor: AppColors.white,
          key: navigationController.scaffoldKey,
          drawer: const SideMenu(),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ResponsiveConstraints(
                  constraints: constraints,
                  child: Builder(
                    builder: (context) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!Responsive.isMobile(context))
                            const SizedBox(
                              width: 250,
                              child: SideMenu(),
                            ),
                          Expanded(
                            child: Column(
                              children: [
                                if (!Responsive.isDesktop(context))
                                  const Header()
                                else
                                  const SizedBox(height: 24), // Top spacing for desktop view
                                Expanded(
                                  child: navigationController.items.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "No Dashboard Access - Please Contact Admin",
                                          ),
                                        )
                                      : KeyedSubtree(
                                          key: ValueKey(navigationController.selectedIndex),
                                          child: SmoothScrollWrapper(
                                            key: ValueKey(navigationController.selectedIndex),
                                            child: navigationController.currentScreen,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
