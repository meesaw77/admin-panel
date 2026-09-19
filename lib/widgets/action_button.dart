import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../theme/colors.dart';

Widget buildFormActionButtons({
  required VoidCallback onSave,
  required VoidCallback onDiscard,
  required bool isLoading,
  String saveText = "Save Changes",
  MainAxisAlignment alignment = MainAxisAlignment.end,
  EdgeInsetsGeometry savePadding = const EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  ),
  double buttonRadius = 5,
  Color loaderColor = AppColors.primaryRed,
}) {
  return Row(
    mainAxisAlignment: alignment,
    children: [
      TextButton(
        onPressed: onDiscard,
        child: const Text("Discard", style: TextStyle(color: AppColors.grey)),
      ),
      const SizedBox(width: 16),
      ElevatedButton(
        onPressed: isLoading ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          padding: savePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: loaderColor,
                  size: 20,
                ),
              )
            : Text(
                saveText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    ],
  );
}
