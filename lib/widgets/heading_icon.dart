import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';

Widget buildHeadingWithIcon(String text, String? svgPath) {
  return Row(
    children: [
      if (svgPath != null && svgPath.isNotEmpty) ...[
        SvgPicture.asset(
          svgPath,
          width: 20,
          height: 20,
        ),
        const SizedBox(width: 8),
      ],
      Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
          letterSpacing: 0.5,
        ),
      ),
    ],
  );
}
