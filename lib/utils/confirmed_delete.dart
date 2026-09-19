import 'package:admin/theme/colors.dart';
import 'package:flutter/material.dart';

void showDeleteConfirm({
  required BuildContext context,
  required String message,
  required VoidCallback onDelete,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text(
        "Confirm Delete",
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content:  Text(
        message,
        style: const TextStyle(color: AppColors.white),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.white,
          ),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            onDelete(); // 🔥 dynamic delete action
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.grey,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text("Delete"),
        ),
      ],
    ),
  );
}
