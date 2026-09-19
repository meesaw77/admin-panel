import 'package:admin/controllers/blogs/blogs_controller.dart';
import 'package:admin/controllers/categories/category_controller.dart';
import 'package:admin/controllers/bookings/bookings_controller.dart';
import 'package:admin/controllers/management/management_controller.dart';
import 'package:admin/controllers/reviews/reviews_controller.dart';
import 'package:admin/controllers/teams/team_controller.dart';
import 'package:admin/controllers/products/product_controller.dart';
import 'package:admin/controllers/services/services_controller.dart';
import 'package:admin/controllers/specialists/specialist_controller.dart';
import 'package:admin/controllers/promotions/promotions_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:admin/theme/layout.dart';
import 'package:admin/screens/dashboard/components/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyFiles extends StatelessWidget {
  const MyFiles({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Responsive(
      mobile: StatCardGridView(
        crossAxisCount: size.width < 650 ? 2 : 3,
        childAspectRatio: size.width < 650 && size.width > 350 ? 1.3 : 1,
      ),
      tablet: const StatCardGridView(
        crossAxisCount: 4,
        childAspectRatio: 1.1,
      ),
      desktop: StatCardGridView(
        crossAxisCount: 5,
        childAspectRatio: size.width < 1400 ? 1.5 : 1.8,
      ),
    );
  }
}

class StatCardGridView extends StatelessWidget {
  const StatCardGridView({
    super.key,
    this.crossAxisCount = 5,
    this.childAspectRatio = 2.0,
  });

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingsController>().bookings;
    final users = context.watch<ManagementController>().users;
    final reviews = context.watch<ReviewsController>().reviews;
    final categories = context.watch<CategoryController>().categories;
    final blogs = context.watch<BlogsController>().blogs;
    final team = context.watch<TeamController>().teamMembers;
    final products = context.watch<ProductController>().products;
    final services = context.watch<ServicesController>().services;
    final specialists = context.watch<SpecialistController>().specialists;
    final promotions = context.watch<PromotionsController>().promotions;

    // Category Stats
    int totalCategories = categories.length;
    int publishedCategories = categories
        .where((c) => c.status == 'Published')
        .length;
    int draftCategories = totalCategories - publishedCategories;

    // Review Stats
    int totalReviewsCount = reviews.length;
    int verifiedReviews = reviews.where((r) => r.isVerified).length;
    int promotedReviews = reviews.where((r) => r.isPromoted).length;

    // Blog Stats
    int totalBlogsCount = blogs.length;
    int publishedBlogs = blogs.where((b) => b.status == 'Published').length;
    int draftBlogs = totalBlogsCount - publishedBlogs;

    // User Stats
    int totalUsersCount = users.length;
    int bannedUsers = users.where((u) => u.isBanned).length;
    int activeUsers = totalUsersCount - bannedUsers;

    // Booking Stats
    int totalBookingsCount = bookings.length;
    int completedBookings = bookings
        .where((b) => b.status.toLowerCase() == 'completed')
        .length;
    int rejectedBookings = bookings
        .where((b) => b.status.toLowerCase() == 'rejected')
        .length;
    int pendingBookings = bookings
        .where((b) => b.status.toLowerCase() == 'pending')
        .length;

    // Team Stats
    int totalTeamCount = team.length;
    int publishedTeam = team.where((m) => m.status == 'Published').length;
    int draftTeam = totalTeamCount - publishedTeam;

    // Product Stats
    int totalProductsCount = products.length;
    int publishedProducts = products
        .where((p) => p.status == 'Published')
        .length;
    int draftProducts = totalProductsCount - publishedProducts;

    // Service Stats
    int totalServicesCount = services.length;
    int publishedServices = services
        .where((s) => s.status == 'Published')
        .length;
    int draftServices = totalServicesCount - publishedServices;

    // Specialist Stats
    int totalSpecialistsCount = specialists.length;
    int publishedSpecialists = specialists
        .where((s) => s.status == 'Published')
        .length;
    int draftSpecialists = totalSpecialistsCount - publishedSpecialists;

    // Promotion Stats
    int totalPromotionsCount = promotions.length;
    int publishedPromotions = promotions
        .where((p) => p.status.toLowerCase() == 'published')
        .length;
    int draftPromotions = totalPromotionsCount - publishedPromotions;

    final List<StatInfo> dynamicStats = [
      StatInfo(
        title: "Collections",
        totalResult: totalCategories.toString(),
        percentage: "${publishedCategories}P / ${draftCategories}D",
        svgSrc: AppIcons.category,
        arrowSvgSrc: AppIcons.cate,
        color: AppColors.primaryRed,
      ),
      StatInfo(
        title: "Feedback",
        totalResult: totalReviewsCount.toString(),
        percentage: "${verifiedReviews}V / ${promotedReviews}P",
        svgSrc: AppIcons.rating,
        arrowSvgSrc: AppIcons.review,
        color: AppColors.primaryRed,
      ),
      StatInfo(
        title: "Articles",
        totalResult: totalBlogsCount.toString(),
        percentage: "${publishedBlogs}P / ${draftBlogs}D",
        svgSrc: AppIcons.blog,
        arrowSvgSrc: AppIcons.blo,
        color: AppColors.primaryRed,
      ),
      StatInfo(
        title: "Staff",
        totalResult: totalUsersCount.toString(),
        percentage: "${activeUsers}P / ${bannedUsers}D",
        svgSrc: AppIcons.users,
        arrowSvgSrc: AppIcons.user,
        color: AppColors.primaryRed,
      ),
      StatInfo(
        title: "Appointments",
        totalResult: totalBookingsCount.toString(),
        percentage:
            "${completedBookings}C / ${rejectedBookings}R / ${pendingBookings}P",
        svgSrc: AppIcons.booking,
        arrowSvgSrc: AppIcons.book,
        color: AppColors.primaryRed,
      ),
      StatInfo(
        title: "Our Team",
        totalResult: totalTeamCount.toString(),
        percentage: "${publishedTeam}P / ${draftTeam}D",
        svgSrc: AppIcons.users,
        arrowSvgSrc: AppIcons.tea,
        color: AppColors.primaryRed,
      ),
      StatInfo(
        title: "Store",
        totalResult: totalProductsCount.toString(),
        percentage: "${publishedProducts}P / ${draftProducts}D",
        svgSrc: AppIcons.product,
        arrowSvgSrc: AppIcons.pro,
        color: AppColors.primaryRed,
      ),
      StatInfo(
        title: "Service",
        totalResult: totalServicesCount.toString(),
        percentage: "${publishedServices}P / ${draftServices}D",
        svgSrc: AppIcons.services,
        arrowSvgSrc: AppIcons.service,
        color: AppColors.primaryRed,
      ),
      StatInfo(
        title: "Experts",
        totalResult: totalSpecialistsCount.toString(),
        percentage: "${publishedSpecialists}P / ${draftSpecialists}D",
        svgSrc: AppIcons.users,
        arrowSvgSrc: AppIcons.spec,
        color: AppColors.primaryRed,
      ),
      StatInfo(
        title: "Offers",
        totalResult: totalPromotionsCount.toString(),
        percentage: "${publishedPromotions}P / ${draftPromotions}D",
        svgSrc: AppIcons.promo,
        arrowSvgSrc: AppIcons.promotion,
        color: AppColors.primaryRed,
      ),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: dynamicStats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppLayout.defaultPadding,
        mainAxisSpacing:
            AppLayout.defaultPadding / 2, // Tighter vertical spacing
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => StatCard(info: dynamicStats[index]),
    );
  }
}
