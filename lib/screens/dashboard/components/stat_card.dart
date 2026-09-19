import 'package:admin/theme/app_icons.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/theme/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StatInfo {
  final String? title, totalResult, percentage;
  final String svgSrc;
  final String? arrowSvgSrc;
  final Color color;

  StatInfo({
    this.title,
    this.totalResult,
    this.percentage,
    required this.svgSrc,
    this.arrowSvgSrc,
    required this.color,
  });
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.info});

  final StatInfo info;

  @override
  Widget build(BuildContext context) {
    bool isStaticType =
        info.title == "Collections" ||
        info.title == "Feedback" ||
        info.title == "Articles" ||
        info.title == "Staff" ||
        info.title == "Appointments" ||
        info.title == "Our Team" ||
        info.title == "Store" ||
        info.title == "Service" ||
        info.title == "Experts" ||
        info.title == "Offers";

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.defaultPadding * 0.6,
        vertical: AppLayout.defaultPadding * 0.25,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (info.arrowSvgSrc != null)
            Positioned(
              top: 10,
              right: 10,
              child: SvgPicture.asset(
                info.arrowSvgSrc!,
                width: 100,
                height: 100,
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.title ?? "Info",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  _buildResultValue(context, info.totalResult ?? "0"),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isStaticType
                          ? AppColors.softBlack.withValues(alpha: 0.06)
                          : ((info.percentage ?? '').startsWith('+')
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isStaticType
                            ? AppColors.softBlack.withValues(alpha: 0.05)
                            : ((info.percentage ?? '').startsWith('+')
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.red.withValues(alpha: 0.15)),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      info.percentage ?? "0",
                      style: TextStyle(
                        color: isStaticType
                            ? AppColors.softBlack.withValues(alpha: 0.6)
                            : ((info.percentage ?? '').startsWith('+')
                                  ? Colors.green[700]
                                  : Colors.red[700]),
                        fontSize: isStaticType
                            ? (info.title == "Appointments" ? 6.5 : 8)
                            : 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultValue(BuildContext context, String value) {
    if (value.startsWith("£")) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppIcons.pound,
            width: 12,
            height: 12,
            colorFilter: const ColorFilter.mode(
              AppColors.softBlack,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value.substring(1),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.softBlack,
              fontSize: 18,
              letterSpacing: -0.6,
            ),
          ),
        ],
      );
    }
    return Text(
      value,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        color: AppColors.softBlack,
        fontSize: 18,
        letterSpacing: -0.6,
      ),
    );
  }
}
