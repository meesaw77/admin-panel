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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/theme/layout.dart';
import 'components/my_fields.dart';
import 'components/recent_files.dart';
import 'components/storage_details.dart';
import 'components/revenue_graph.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    final bookingsController = context.read<BookingsController>();
    final managementController = context.read<ManagementController>();
    final reviewsController = context.read<ReviewsController>();
    final categoryController = context.read<CategoryController>();
    final blogsController = context.read<BlogsController>();
    final teamController = context.read<TeamController>();
    final productController = context.read<ProductController>();
    final servicesController = context.read<ServicesController>();
    final specialistController = context.read<SpecialistController>();
    final promotionsController = context.read<PromotionsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      bookingsController.fetchBookings(silent: true);
      managementController.fetchUsers();
      reviewsController.fetchReviews(isSilent: true);
      categoryController.fetchCategories();
      blogsController.fetchBlogs();
      teamController.fetchTeamMembers();
      productController.fetchProducts();
      servicesController.fetchServices();
      specialistController.fetchSpecialists();
      promotionsController.fetchPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.defaultPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyFiles(),
            if (!Responsive.isMobile(context))
              const SizedBox(height: AppLayout.defaultPadding / 2),
            if (Responsive.isMobile(context))
              const SizedBox(height: AppLayout.defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!Responsive.isMobile(context))
                  const Expanded(flex: 4, child: RevenueGraph()),
                if (!Responsive.isMobile(context))
                  const SizedBox(width: AppLayout.defaultPadding),
                if (!Responsive.isMobile(context))
                  const Expanded(flex: 3, child: RecentFiles()),
                if (!Responsive.isMobile(context))
                  const SizedBox(width: AppLayout.defaultPadding),
                if (!Responsive.isMobile(context))
                  const Expanded(flex: 3, child: StorageDetails()),
                if (Responsive.isMobile(context))
                  const Expanded(
                    child: Column(
                      children: [
                        RevenueGraph(),
                        SizedBox(height: AppLayout.defaultPadding),
                        RecentFiles(),
                        SizedBox(height: AppLayout.defaultPadding),
                        StorageDetails(),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
