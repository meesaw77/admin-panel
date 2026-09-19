import 'package:admin/controllers/blogs/blogs_controller.dart';
import 'package:admin/controllers/bookings/bookings_controller.dart';
import 'package:admin/controllers/categories/category_controller.dart';
import 'package:admin/controllers/dashboard/dashboard_ui_controller.dart';
import 'package:admin/controllers/navigation_controller.dart';
import 'package:admin/controllers/products/product_form_controller.dart';
import 'package:admin/controllers/products/product_controller.dart';
import 'package:admin/controllers/specialists/specialist_controller.dart';
import 'package:admin/controllers/services/services_controller.dart';
import 'package:admin/controllers/promotions/promotions_controller.dart';
import 'package:admin/controllers/reviews/reviews_controller.dart';
import 'package:admin/controllers/auth_controller.dart';
import 'package:admin/controllers/management/management_controller.dart';
import 'package:admin/controllers/management/membership_controller.dart';
import 'package:admin/controllers/teams/team_controller.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/screens/auth/login_screen.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean URL: Removes the '#' from the URL
  usePathUrlStrategy();

  final authController = AuthController();

  runApp(MyApp(authController: authController));
}

class MyApp extends StatelessWidget {
  final AuthController authController;

  const MyApp({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authController),
        ChangeNotifierProxyProvider<AuthController, NavigationController>(
          create: (context) => NavigationController(),
          update: (context, auth, nav) => nav!..update(auth),
        ),
        ChangeNotifierProxyProvider<AuthController, BookingsController>(
          create: (context) => BookingsController(),
          update: (context, auth, bookings) => bookings!..update(auth),
        ),
        ChangeNotifierProvider(create: (context) => BlogsController()),
        ChangeNotifierProvider(create: (context) => ServicesController()),
        ChangeNotifierProvider(create: (context) => DashboardUIController()),
        ChangeNotifierProvider(create: (context) => ProductFormController()),
        ChangeNotifierProvider(create: (context) => CategoryController()),
        ChangeNotifierProvider(create: (context) => SpecialistController()),
        ChangeNotifierProvider(create: (context) => ProductController()),
        ChangeNotifierProvider(create: (context) => PromotionsController()),
        ChangeNotifierProvider(create: (context) => ReviewsController()),
        ChangeNotifierProvider(create: (context) => TeamController()),
        ChangeNotifierProvider(create: (context) => ManagementController()),
        ChangeNotifierProvider(create: (context) => MembershipController()),
      ],
      child: Consumer<AuthController>(
        builder: (context, auth, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FullStop Aesthetic Admin',
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.grey,
              fontFamily: 'Satoshi',
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primaryRed,
                primary: AppColors.primaryRed,
                brightness: Brightness.dark,
              ),
              textTheme: Theme.of(context).textTheme.apply(
                bodyColor: AppColors.white,
                fontFamily: 'Satoshi',
              ),
              canvasColor: AppColors.grey,
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primaryRed;
                  }
                  return Colors.transparent;
                }),
                checkColor: WidgetStateProperty.all(Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: AppColors.grey, width: 1),
              ),
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(
                  AppColors.primaryRed.withValues(alpha: 0.7),
                ),
                trackColor: WidgetStateProperty.all(
                  AppColors.grey.withValues(alpha: 0.05),
                ),
                thickness: WidgetStateProperty.all(8),
                radius: const Radius.circular(4),
                interactive: true,
              ),
            ),

            key: ValueKey(auth.isAuthenticated),
            home: auth.isAuthenticated
                ? const MainScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
