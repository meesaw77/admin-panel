import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

class FullStopLogo extends StatelessWidget {
  final bool isLightBackground;

  const FullStopLogo({super.key, this.isLightBackground = false});

  @override
  Widget build(BuildContext context) {
    final Color textColor = isLightBackground
        ? AppColors.softBlack
        : AppColors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        // If the width is less than 100, we show the 'Mini' version
        bool isNarrow = constraints.maxWidth < 100;

        if (isNarrow) {
          return Center(
            child: Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'AESTHETICS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 4.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }

        // Default Full Version for Desktop/Wide views
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'FULL',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryRed,
                  fontFamily: 'Libre',
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ST',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  fontFamily: 'Libre',
                ),
              ),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'AESTHETICS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 4.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Text(
                'P',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  letterSpacing: 2.0,
                  fontFamily: 'Libre',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
