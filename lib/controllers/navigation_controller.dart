import 'package:admin/models/navigation_item.dart';
import 'package:admin/screens/blogs/blogs_screen.dart';
import 'package:admin/screens/bookings/bookings_screen.dart';
import 'package:admin/screens/dashboard/dashboard.dart';
import 'package:admin/screens/category/category_screen.dart';
import 'package:admin/screens/reviews/reviews_screen.dart';
import 'package:admin/screens/services/services_screen.dart';
import 'package:admin/screens/specialists/specialists_screen.dart';
import 'package:admin/screens/products/products_screen.dart';
import 'package:admin/screens/promotions/promotions_screen.dart';
import 'package:admin/screens/management/management_screen.dart';
import 'package:admin/screens/management/membership_screen.dart';
import 'package:admin/screens/teams/teams_screen.dart';
import 'package:admin/controllers/auth_controller.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:admin/components/smooth_scroll_wrapper.dart';
import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  AuthController? authController;
  int? _lastUserId;

  NavigationController({this.authController});

  void update(AuthController auth) {
    authController = auth;
    final currentUserId = auth.currentUser?.id;
    if (currentUserId != _lastUserId) {
      _lastUserId = currentUserId;
      _selectedIndex = 0;
      notifyListeners();
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  final List<NavigationItem> _items = const [
    NavigationItem(
      title: "Overview",
      svgSrc: AppIcons.analytic,
      screen: Dashboard(),
      path: "overview",
    ),
    NavigationItem(
      title: "Staff",
      svgSrc: AppIcons.users,
      screen: ManagementScreen(),
      path: "staff",
    ),
    NavigationItem(
      title: "Offers",
      svgSrc: AppIcons.promo,
      screen: PromotionsScreen(),
      path: "offers",
    ),
    NavigationItem(
      title: "Collections",
      svgSrc: AppIcons.category,
      screen: CategoryScreen(),
      path: "collections",
    ),
    NavigationItem(
      title: "Appointments",
      svgSrc: AppIcons.booking,
      screen: BookingsScreen(),
      path: "appointments",
    ),
    NavigationItem(
      title: "Store",
      svgSrc: AppIcons.prod,
      screen: ProductsScreen(),
      path: "store",
    ),
    NavigationItem(
      title: "Services",
      svgSrc: AppIcons.services,
      screen: ServicesScreen(),
      path: "services",
    ),
    NavigationItem(
      title: "Experts",
      svgSrc: AppIcons.specialist,
      screen: SpecialistsScreen(),
      path: "experts",
    ),
    NavigationItem(
      title: "Feedback",
      svgSrc: AppIcons.rating,
      screen: ReviewsScreen(),
      path: "feedback",
    ),
    NavigationItem(
      title: "Articles",
      svgSrc: AppIcons.blogging,
      screen: BlogsScreen(),
      path: "articles",
    ),
    NavigationItem(
      title: "Our Team",
      svgSrc: AppIcons.team,
      screen: TeamsScreen(),
      path: "team",
    ),
    NavigationItem(
      title: "Membership",
      svgSrc: AppIcons.membership,
      screen: MembershipScreen(),
      path: "membership",
    ),
  ];

  List<NavigationItem> get items {
    final user = authController?.currentUser;
    if (user != null && user.role.toLowerCase() != 'admin') {
      final assignedWork = user.assignedWork ?? '';
      final List<String> allowedTitles = ["Appointments"];

      if (assignedWork.contains('Blogs')) allowedTitles.add("Articles");
      if (assignedWork.contains('Services')) allowedTitles.add("Services");
      if (assignedWork.contains('Teams')) allowedTitles.add("Our Team");
      if (assignedWork.contains('Reviews')) allowedTitles.add("Feedback");
      if (assignedWork.contains('Category')) allowedTitles.add("Collections");
      if (assignedWork.contains('Products')) allowedTitles.add("Store");
      if (assignedWork.contains('Management')) allowedTitles.add("Staff");
      if (assignedWork.contains('Specialist')) allowedTitles.add("Experts");
      if (assignedWork.contains('Promotions')) allowedTitles.add("Offers");
      if (assignedWork.contains('Membership')) allowedTitles.add("Membership");

      final filtered = _items
          .where((item) => allowedTitles.contains(item.title))
          .toList();

      filtered.sort((a, b) {
        if (a.title == "Appointments") return -1;
        if (b.title == "Appointments") return 1;
        return 0;
      });

      return filtered;
    }
    return _items;
  }

  List<Widget> get screens => items
      .map((item) => SmoothScrollWrapper(
            key: ValueKey(item.path),
            child: item.screen,
          ))
      .toList();

  Widget get currentScreen {
    if (items.isEmpty) return const SizedBox();
    final clampedIndex = _selectedIndex.clamp(0, items.length - 1);
    return items[clampedIndex].screen;
  }

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  void setSelectedIndex(int index) {
    if (index >= 0 && index < items.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void setSelectedByTitle(String title) {
    final index = items.indexWhere((item) => item.title == title);
    if (index != -1) {
      setSelectedIndex(index);
    }
  }
}
