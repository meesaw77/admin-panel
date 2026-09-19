
import 'package:admin/widgets/status.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_icons.dart';
import '../theme/colors.dart';
import 'heading_icon.dart';

Widget buildVisibilityStatusSection({
  required String currentStatus,
  required ValueChanged<String> onStatusChanged,
  String iconPath = AppIcons.visible,
  double horizontalPadding = 20,
  double borderRadius = 8,
  double spacing = 12,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildHeadingWithIcon("Visibility Status", iconPath),
      SizedBox(height: spacing),
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildStatusOption(
              "Published",
              currentStatus == "Published",
              onStatusChanged,
              horizontalPadding: horizontalPadding,
              borderRadius: borderRadius,
            ),
            buildStatusOption(
              "Draft",
              currentStatus == "Draft",
              onStatusChanged,
              horizontalPadding: horizontalPadding,
              borderRadius: borderRadius,
            ),
          ],
        ),
      ),
    ],
  );
}
