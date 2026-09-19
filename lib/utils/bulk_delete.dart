import 'package:flutter/material.dart';

Future<void> showBulkDeleteDialog({
  required BuildContext context,
  required int count,
  required String itemNamePlural,
  required VoidCallback onConfirm,

  String title = "Confirm Bulk Delete",
  String cancelText = "Cancel",
  String confirmText = "Delete All",

  Color backgroundColor = Colors.white,
  Color titleColor = Colors.black,
  Color contentColor = Colors.black,
  Color cancelColor = Colors.black,
  Color confirmBackgroundColor = Colors.red,
  Color confirmTextColor = Colors.white,

  double dialogRadius = 16,
  double buttonRadius = 8,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dialogRadius),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        "Are you sure you want to delete $count $itemNamePlural?",
        style: TextStyle(color: contentColor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: cancelColor,
          ),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmBackgroundColor,
            foregroundColor: confirmTextColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
