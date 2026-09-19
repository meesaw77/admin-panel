import 'package:admin/controllers/bookings/bookings_controller.dart';
import 'package:admin/controllers/reviews/reviews_controller.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:admin/theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:admin/theme/layout.dart';

class RecentFiles extends StatelessWidget {
  const RecentFiles({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<ReviewsController>().reviews;
    final bookings = context.watch<BookingsController>().bookings;

    // Calculate Average Ranking
    double avgRanking = 0;
    if (reviews.isNotEmpty) {
      double totalRating = 0;
      for (var review in reviews) {
        totalRating += review.rating;
      }
      avgRanking = totalRating / reviews.length;
    }

    // Prepare Bar Chart Data (Bookings by Status)
    Map<String, int> statusCounts = {
      'Pending': 0,
      'Confirmed': 0,
      'Completed': 0,
      'Rejected': 0,
    };

    for (var b in bookings) {
      final s = b.status.toLowerCase();
      if (s == 'pending' || s == 'waiting') {
        statusCounts['Pending'] = (statusCounts['Pending'] ?? 0) + 1;
      } else if (s == 'confirmed' || s == 'approved') {
        statusCounts['Confirmed'] = (statusCounts['Confirmed'] ?? 0) + 1;
      } else if (s == 'completed') {
        statusCounts['Completed'] = (statusCounts['Completed'] ?? 0) + 1;
      } else if (s == 'rejected' || s == 'cancelled' || s == 'failed') {
        statusCounts['Rejected'] = (statusCounts['Rejected'] ?? 0) + 1;
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
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: AppColors.softBlack.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SvgPicture.asset(
                        AppIcons.analytic,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryRed,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Booking analytics",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.softBlack,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Average ranking: ${avgRanking.toStringAsFixed(1)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.softBlack.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.primaryRed.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  "Real-time",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppLayout.defaultPadding),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    (statusCounts.values.isEmpty
                            ? 5
                            : statusCounts.values.reduce(
                                    (a, b) => a > b ? a : b,
                                  ) +
                                  2)
                        .toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: AppColors.softBlack,
                          fontSize: 10,
                        );
                        String text = '';
                        switch (value.toInt()) {
                          case 0:
                            text = 'PENDING';
                            break;
                          case 1:
                            text = 'CONFIRM';
                            break;
                          case 2:
                            text = 'DONE';
                            break;
                          case 3:
                            text = 'REJECT';
                            break;
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 10,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 10,
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  makeGroupData(
                    0,
                    statusCounts['Pending']!.toDouble(),
                    AppColors.grey,
                  ),
                  makeGroupData(
                    1,
                    statusCounts['Confirmed']!.toDouble(),
                    const Color(0xFFFFCF26),
                  ),
                  makeGroupData(
                    2,
                    statusCounts['Completed']!.toDouble(),
                    AppColors.primaryRed,
                  ),
                  makeGroupData(
                    3,
                    statusCounts['Rejected']!.toDouble(),
                    const Color(0xFFEE2727),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: y + 2,
            color: color.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
