import 'package:admin/controllers/navigation_controller.dart';
import 'package:admin/controllers/auth_controller.dart';
import 'package:admin/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'user_profile_header.dart';
import 'full_stop_logo.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  void _closeDrawerIfOpen(BuildContext context) {
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState != null && scaffoldState.isDrawerOpen) {
      scaffoldState.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.softBlack,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Consumer<NavigationController>(
        builder: (context, nav, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // Determine if the drawer is in "narrow" mode (collapsed)
              bool isNarrow = constraints.maxWidth < 180;

              return SafeArea(
                child: Column(
                  children: [
                    // ---------------- USER PROFILE SECTION ----------------
                    // Always show Profile in Sidebar (Reverted)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: UserProfileHeader(
                        isNarrow: isNarrow,
                        isDark: true, // Use white text for dark background
                      ),
                    ),

                    // ---------------- MENU ITEMS ----------------
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // Logo - Always show in Sidebar if not narrow (Reverted)
                          if (!isNarrow)
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                              child: FullStopLogo(isLightBackground: false),
                            ),

                          // Menu List
                          ...nav.items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;

                            return DrawerListTile(
                              title: isNarrow ? "" : item.title,
                              svgSrc: item.svgSrc,
                              isSelected: nav.selectedIndex == index,
                              press: () {
                                nav.setSelectedIndex(index);

                                // ✅ Close drawer on mobile after selection
                                _closeDrawerIfOpen(context);
                              },
                            );
                          }),
                        ],
                      ),
                    ),

                    Divider(
                      color: AppColors.white.withValues(alpha: 0.2),
                      thickness: 0.5,
                    ),

                    // ---------------- LOGOUT ----------------
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Consumer<AuthController>(
                        builder: (context, auth, child) {
                          return ListTile(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () {
                              auth.logout();

                              // ✅ Close drawer on mobile
                              _closeDrawerIfOpen(context);
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.white54,
                              size: 20,
                            ),
                            title: isNarrow
                                ? null
                                : const Text(
                                    "Sign Out",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.press,
    required this.isSelected,
  });

  final String title, svgSrc;
  final VoidCallback press;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isNarrow = constraints.maxWidth < 180;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            hoverColor: Colors.white.withValues(alpha: 0.08),
            onTap: press,
            borderRadius: BorderRadius.circular(6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: isNarrow ? 45 : 55,
              width: isNarrow ? 45 : double.infinity,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryRed : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: isNarrow
                  ? Center(
                      child: SvgPicture.asset(
                        svgSrc,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          isSelected ? AppColors.white : Colors.white54,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.white
                                    : Colors.white54,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: SvgPicture.asset(
                                svgSrc,
                                height: 20,
                                width: 20,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? AppColors.white
                                      : AppColors.white.withValues(alpha: 0.3),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
