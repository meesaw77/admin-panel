import 'package:flutter/material.dart';
import '../theme/colors.dart';

Widget buildStatusOption(
    String title,
    bool isSelected,
    ValueChanged<String> onTap, {
      double horizontalPadding = 16,
      double verticalPadding = 8,
      double fontSize = 12,
      double borderRadius = 6,
    }) {
  return InkWell(
    onTap: () => onTap(title),
    borderRadius: BorderRadius.circular(borderRadius),
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ]
            : null,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primaryRed : AppColors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: fontSize,
        ),
      ),
    ),
  );
}
