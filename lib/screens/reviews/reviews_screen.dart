import 'package:admin/controllers/reviews/reviews_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/services/api_service.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../utils/bulk_delete.dart';
import '../../utils/confirmed_delete.dart';
import '../../widgets/icon_button.dart';
import 'package:admin/widgets/custom_horizontal_scrollbar.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late ReviewsController _controller;

  static const double _minTableWidth = 750;

  @override
  void initState() {
    super.initState();
    _controller = context.read<ReviewsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.fetchReviews();
      _controller.startPolling();
    });
  }

  @override
  void dispose() {
    _controller.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Consumer<ReviewsController>(
        builder: (context, controller, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Responsive(
                  mobile: Column(
                    children: [
                      _buildHeaderTitle(controller),
                      const SizedBox(height: 16),
                      _buildHeaderSearch(controller),
                    ],
                  ),
                  desktop: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderTitle(controller),
                      _buildHeaderSearch(controller),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.fetchReviews,
                    color: AppColors.primaryRed,
                    child: Scrollbar(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildListHeader(context, controller),
                          const SizedBox(height: 16),
                          _buildReviewsList(context, controller),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderTitle(ReviewsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Reviews & Testimonials",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.softBlack,
                fontFamily: "Libre",
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Moderate client feedback and promote top reviews",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSearch(ReviewsController controller) {
    return SizedBox(
      width: 320,
      height: 45,
      child: TextField(
        onChanged: controller.setSearchQuery,
        style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
        decoration: InputDecoration(
          hintText: "Search by client or comment...",
          hintStyle: TextStyle(
            color: AppColors.grey.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              AppIcons.search,
              colorFilter: ColorFilter.mode(
                AppColors.grey.withValues(alpha: 0.5),
                BlendMode.srcIn,
              ),
            ),
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.grey, width: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, ReviewsController controller) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "Total Reviews: ${controller.filteredReviews.length}",
            style: const TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        if (controller.selectedIds.isNotEmpty) ...[
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              showBulkDeleteDialog(
                context: context,
                count: controller.selectedIds.length,
                itemNamePlural: "reviews",
                onConfirm: () => controller.bulkDelete(controller.selectedIds),
                backgroundColor: AppColors.grey,
                titleColor: AppColors.white,
                contentColor: AppColors.white,
                cancelColor: AppColors.white,
                confirmBackgroundColor: AppColors.grey,
                confirmTextColor: AppColors.white,
                dialogRadius: 6,
                buttonRadius: 6,
              );
            },
            icon: SvgPicture.asset(
              AppIcons.trash,
              width: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            label: Text("Delete (${controller.selectedIds.length})"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewsList(BuildContext context, ReviewsController controller) {
    if (controller.isLoading && controller.reviews.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: AppColors.primaryRed,
            size: 20,
          ),
        ),
      );
    }

    if (controller.reviews.isEmpty) {
      return _emptyState(
        title: "No reviews yet",
        subtitle: "Once clients submit feedback, you’ll see it here.",
      );
    }

    if (controller.filteredReviews.isEmpty) {
      return _emptyState(
        title: "No results found",
        subtitle: "Try a different name or keyword.",
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth = constraints.maxWidth > _minTableWidth
            ? constraints.maxWidth
            : _minTableWidth;

        final total = controller.filteredReviews.length;
        final selected = controller.selectedIds.length;
        final bool allSelected = total > 0 && selected == total;
        final bool noneSelected = selected == 0;

        // true = all, false = none, null = partial
        final bool? headerValue = total == 0
            ? false
            : (noneSelected ? false : (allSelected ? true : null));

        return CustomHorizontalScrollbar(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
            width: tableWidth,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          tristate: true,
                          value: headerValue,
                          onChanged: (val) => controller.selectAll(val == true),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: _buildTableHeaderText("Client"),
                        ),
                        Expanded(
                          flex: 4,
                          child: _buildTableHeaderText("Comment"),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          flex: 2,
                          child: _buildTableHeaderText("Rating"),
                        ),
                        Expanded(flex: 2, child: _buildTableHeaderText("Date")),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Actions".toUpperCase(),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 0.1, color: Colors.grey[200]),

                  // List Items
                  Column(
                    children: [
                      ...List.generate(controller.filteredReviews.length, (
                        index,
                      ) {
                        final review = controller.filteredReviews[index];
                        final bool isSelected = controller.selectedIds.contains(
                          review.id,
                        );

                        return Column(
                          children: [
                            InkWell(
                              hoverColor: AppColors.primaryRed.withValues(
                                alpha: 0.05,
                              ),
                              onTap: () =>
                                  controller.toggleSelection(review.id),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (_) =>
                                          controller.toggleSelection(review.id),
                                    ),
                                    const SizedBox(width: 8),

                                    // Client Info
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          _buildAvatar(
                                            imageUrl: review.userImage,
                                            userName: review.userName,
                                            size: 40,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  review.isPromoted
                                                      ? "TOP REVIEW"
                                                      : "CLIENT",
                                                  style: TextStyle(
                                                    color: AppColors.primaryRed
                                                        .withValues(alpha: 0.8),
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 1.1,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        review.userName,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .softBlack,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    if (review.userImage !=
                                                            null &&
                                                        review.userImage!
                                                            .contains(
                                                              'googleusercontent',
                                                            )) ...[
                                                      const SizedBox(width: 4),
                                                      SvgPicture.asset(
                                                        AppIcons.google,
                                                        width: 14,
                                                        height: 14,
                                                      ),
                                                    ],
                                                    if (review.isVerified) ...[
                                                      const SizedBox(width: 4),
                                                      buildActionIcon(
                                                        svgPath:
                                                            AppIcons.verify,
                                                        color: Colors.blue,
                                                        onTap: () {},
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Comment
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        review.comment,
                                        style: const TextStyle(
                                          color: AppColors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 24),

                                    // Rating
                                    Expanded(
                                      flex: 2,
                                      child: _buildRatingStars(review.rating),
                                    ),

                                    // Date
                                    Expanded(
                                      flex: 2,
                                      child: Builder(
                                        builder: (context) {
                                          try {
                                            final dateTime = DateTime.parse(
                                              review.date,
                                            );
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  DateFormat(
                                                    'MMM dd, yyyy',
                                                  ).format(dateTime),
                                                  style: const TextStyle(
                                                    color: AppColors.softBlack,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat(
                                                    'hh:mm a',
                                                  ).format(dateTime),
                                                  style: TextStyle(
                                                    color: AppColors.grey
                                                        .withValues(alpha: 0.8),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            );
                                          } catch (e) {
                                            return Text(
                                              review.date,
                                              style: const TextStyle(
                                                color: AppColors.grey,
                                                fontSize: 13,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),

                                    // Actions
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          buildActionIcon(
                                            svgPath: AppIcons.confirmed,
                                            color: review.isVerified
                                                ? AppColors.primaryRed
                                                : AppColors.grey,
                                            onTap: () =>
                                                controller.toggleVerify(
                                                  review.id,
                                                  review.isVerified,
                                                ),
                                          ),
                                          const SizedBox(width: 12),
                                          buildActionIcon(
                                            svgPath: AppIcons.promote,
                                            color: review.isPromoted
                                                ? AppColors.primaryRed
                                                : AppColors.grey,
                                            onTap: () =>
                                                controller.togglePromote(
                                                  review.id,
                                                  review.isPromoted,
                                                ),
                                          ),
                                          const SizedBox(width: 12),
                                          buildActionIcon(
                                            svgPath: AppIcons.trash,
                                            color: AppColors.primaryRed,
                                            onTap: () => showDeleteConfirm(
                                              context: context,
                                              message:
                                                  "Are you sure you want to delete this review ?",
                                              onDelete: () => controller
                                                  .deleteReview(review.id),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < controller.filteredReviews.length - 1)
                              Divider(
                                height: 1,
                                thickness: 0.1,
                                color: AppColors.grey.withValues(alpha: 0.1),
                              ),
                          ],
                        );
                      }),
                      if (controller.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
            );
          },
        );
      },
    );
  }

  Widget _emptyState({required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppIcons.testimonial,
            width: 80,
            colorFilter: ColorFilter.mode(
              AppColors.softBlack.withValues(alpha: 0.1),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.softBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.grey.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    final int fullStars = rating.floor().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: SvgPicture.asset(
            AppIcons.star,
            width: 18,
            colorFilter: ColorFilter.mode(
              index < fullStars
                  ? Colors.amber
                  : AppColors.grey.withValues(alpha: 0.2),
              BlendMode.srcIn,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAvatar({
    String? imageUrl,
    required String userName,
    double size = 40,
  }) {
    return Container(
      // ✅ FIXED: now respects the size param
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? AppNetworkImage(
              imageUrl: ApiService.getImageUrl(imageUrl),
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.primaryRed,
                  size: 20,
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
    );
  }

  Widget _buildTableHeaderText(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.grey,
        letterSpacing: 1.1,
      ),
    );
  }
}
