import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../theme/colors.dart';

Widget buildActionIcon({
  required String svgPath,
  required VoidCallback onTap,
  Color color = AppColors.primaryRed,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SvgPicture.asset(
        svgPath,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    ),
  );
}
