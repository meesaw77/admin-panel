import 'package:admin/responsive.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:admin/screens/main/components/full_stop_logo.dart';
import 'package:admin/screens/main/components/user_profile_header.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Responsive.isDesktop(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      // Set background to white as requested
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isDesktop)
            const FullStopLogo(isLightBackground: true)
          else if (!Responsive.isDesktop(context))
            IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: SvgPicture.asset(
                AppIcons.drawer,
                height: 24,
                width: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.softBlack,
                  BlendMode.srcIn,
                ),
              ),
            ),
          
          if (isDesktop)
            const Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: UserProfileHeader(isDark: false),
              ),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
