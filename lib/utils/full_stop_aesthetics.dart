import 'package:flutter/cupertino.dart';
import '../theme/colors.dart';

Widget buildLogo() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        'FULL',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w500,
          letterSpacing: 8,
          height: 1,
          color: AppColors.primaryRed,
          fontFamily: 'Libre',
        ),
      ),
      const SizedBox(width: 2),
      Text(
        'ST',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w500,
          letterSpacing: 8,
          height: 1,
          color: AppColors.grey,
          fontFamily: 'Libre',
        ),
      ),
      const SizedBox(width: 6),
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withValues(alpha: 0.55),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'AESTHETICS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 4,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.white,
          ),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        'P',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w300,
          letterSpacing: 8,
          height: 1,
          color: AppColors.grey,
          fontFamily: 'Libre',
        ),
      ),
    ],
  );
}
