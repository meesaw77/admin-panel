import 'package:admin/theme/colors.dart';
import 'package:flutter/material.dart';

class SnackBarUtils {
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.black,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: isError ? AppColors.primaryRed : Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.softBlack.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        width: 380,
        elevation: 0,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isError 
                ? AppColors.primaryRed.withValues(alpha: 0.5) 
                : AppColors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
    );
  }
}
