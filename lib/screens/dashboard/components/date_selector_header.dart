import 'package:admin/controllers/dashboard/dashboard_ui_controller.dart';
import 'package:admin/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DateSelectorHeader extends StatelessWidget {
  const DateSelectorHeader({super.key});

  List<Map<String, String>> get _dynamicDays {
    final now = DateTime.now();
    // Find the most recent Monday
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(6, (index) {
      final date = monday.add(Duration(days: index));
      return {
        "day": _getDayLabel(date.weekday),
        "date": date.day.toString(),
        "fullDate":
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      };
    });
  }

  String _getDayLabel(int weekday) {
    switch (weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiController = context.watch<DashboardUIController>();
    final selectedIndex = uiController.selectedDateIndex;
    final days = _dynamicDays;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(days.length, (index) {
          bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () {
              uiController.setSelectedDateIndex(index);
              uiController.setSelectedDateString(days[index]["fullDate"]!);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryRed : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryRed
                      : Colors.grey.withValues(alpha: 0.1),
                  width: 0.5,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primaryRed.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    days[index]["day"]!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    days[index]["date"]!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.softBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
