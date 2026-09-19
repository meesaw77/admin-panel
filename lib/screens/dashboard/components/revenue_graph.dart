import 'package:admin/controllers/bookings/bookings_controller.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:admin/theme/layout.dart';
import 'package:intl/intl.dart';

class RevenueGraph extends StatelessWidget {
  const RevenueGraph({super.key});

  String _formatDateLabel(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('d MMM').format(parsed); // e.g., "14 Jun"
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime12h(String time) {
    if (time.isEmpty) return "Time N/A";
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hours = int.parse(parts[0].trim());
        final minutes = int.parse(parts[1].trim());
        final ampm = hours >= 12 ? 'PM' : 'AM';
        final displayHours =
            hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);
        final displayMinutes = minutes.toString().padLeft(2, '0');
        return '$displayHours:$displayMinutes $ampm';
      }
      return time;
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingsController>(
      builder: (context, controller, child) {
        final bookings = controller.bookings
            .where((b) => b.status.toLowerCase() == 'completed')
            .toList();

        // Sort chronologically (oldest first)
        bookings.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return -1;
          if (b.date == null) return 1;
          try {
            final aDate = DateTime.parse(a.date!.split(' ')[0]);
            final bDate = DateTime.parse(b.date!.split(' ')[0]);
            if (aDate.isAtSameMomentAs(bDate)) {
              if (a.time != null && b.time != null) {
                return a.time!.compareTo(b.time!);
              }
            }
            return aDate.compareTo(bDate);
          } catch (_) {
            return a.date!.compareTo(b.date!);
          }
        });

        double totalRevenue = 0;
        double maxPrice = 0;

        for (var b in bookings) {
          double price = double.tryParse(
                b.price?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0',
              ) ??
              0;
          totalRevenue += price;
          if (price > maxPrice) {
            maxPrice = price;
          }
        }

        final double chartMaxY =
            maxPrice > 0 ? (maxPrice * 1.15).ceilToDouble() : 100.0;

        List<BarChartGroupData> barGroups = [];
        if (bookings.isEmpty) {
          barGroups = List.generate(4, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: 0,
                  color: AppColors.primaryRed,
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100.0,
                    color: AppColors.primaryRed.withValues(alpha: 0.05),
                  ),
                ),
              ],
            );
          });
        } else {
          for (int i = 0; i < bookings.length; i++) {
            double price = double.tryParse(
                  bookings[i].price?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0',
                ) ??
                0;

            barGroups.add(
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: price,
                    color: AppColors.primaryRed,
                    width: 20,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: chartMaxY,
                      color: AppColors.primaryRed.withValues(alpha: 0.05),
                    ),
                  ),
                ],
              ),
            );
          }
        }

        return Container(
          height: 420,
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.defaultPadding,
            vertical: AppLayout.defaultPadding / 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(
              color: AppColors.softBlack.withValues(alpha: 0.05),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Revenue Analytics",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.softBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IncomeBadge(totalRevenue: totalRevenue),
                ],
              ),
              const SizedBox(height: AppLayout.defaultPadding),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: chartMaxY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) =>
                            AppColors.softBlack.withValues(alpha: 0.8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          int idx = group.x.toInt();
                          if (idx >= 0 && idx < bookings.length) {
                            final b = bookings[idx];
                            String dateLabel = b.date != null
                                ? _formatDateLabel(b.date!.split(' ')[0])
                                : 'Date N/A';
                            String timeLabel = b.time != null
                                ? _formatTime12h(b.time!)
                                : 'Time N/A';
                            double val = rod.toY;
                            return BarTooltipItem(
                              '$dateLabel • $timeLabel\nRevenue: £${val.toStringAsFixed(2)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval:
                          (chartMaxY > 0 ? chartMaxY / 4 : 25),
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.grey.withValues(alpha: 0.05),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class IncomeBadge extends StatelessWidget {
  final double totalRevenue;
  const IncomeBadge({super.key, required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(
          color: AppColors.primaryRed.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppIcons.pound,
            width: 12,
            height: 12,
            colorFilter: const ColorFilter.mode(
              AppColors.primaryRed,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            totalRevenue.toStringAsFixed(2),
            style: const TextStyle(
              color: AppColors.primaryRed,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
