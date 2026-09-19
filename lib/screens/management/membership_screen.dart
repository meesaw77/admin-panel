import 'package:admin/controllers/management/membership_controller.dart';
import 'package:admin/controllers/services/services_controller.dart';
import 'package:admin/services/api_service.dart';
import 'package:admin/responsive.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:admin/widgets/app_network_image.dart';
import 'package:admin/controllers/categories/category_controller.dart';
import 'package:admin/models/service_model.dart';
import 'package:admin/models/membership_purchase_model.dart';
import '../../widgets/action_button.dart';
import '../../widgets/icon_button.dart';
import 'package:admin/widgets/custom_horizontal_scrollbar.dart';
import 'package:admin/utils/snack_bar_utils.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  late MembershipController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<MembershipController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.fetchMemberships();
        _controller.fetchPurchases();
        _controller.startPolling();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = context.read<MembershipController>();
  }

  @override
  void dispose() {
    _controller.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MembershipController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: controller.isAdding
              ? _buildMembershipForm(controller)
              : _buildMembershipListPage(controller),
        );
      },
    );
  }

  Widget _buildMembershipListPage(MembershipController controller) {
    bool isMobile = Responsive.isMobile(context);
    return Column(
      children: [
        // FIXED HEADER SECTION
        Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Title and Add Button
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Memberships",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.softBlack,
                        fontFamily: 'Libre',
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => controller.setAdding(true),
                      icon: SvgPicture.asset(
                        AppIcons.plus,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: const Text(
                        "Add Membership",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // SCROLLABLE DATA CONTAINER
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchMemberships();
              await controller.fetchPurchases();
            },
            color: AppColors.primaryRed,
            child: Scrollbar(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12.0 : 24.0,
                  vertical: 0,
                ),
                children: [
                  // Row 2: Search and Member Count
                  Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: isMobile
                        ? CrossAxisAlignment.stretch
                        : CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Total Memberships
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (controller.selectedMembershipIds.isNotEmpty) ...[
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppColors.grey,
                                    title: const Text("Delete Selected"),
                                    content: Text(
                                      "Are you sure you want to delete ${controller.selectedMembershipIds.length} memberships?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          controller
                                              .deleteSelectedMemberships();
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Delete Selected",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Total Memberships: ${controller.memberships.length}",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Search Field
                      SizedBox(
                        width: isMobile ? double.infinity : 300,
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            onChanged: (value) =>
                                controller.setSearchQuery(value),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.softBlack,
                            ),
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.search,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                              hintText: "Search memberships...",
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(bottom: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (controller.isLoading && controller.memberships.isEmpty)
                    const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryRed,
                        ),
                      ),
                    )
                  else ...[
                    _buildMembershipListRows(controller),
                    const SizedBox(height: 48),
                    _buildPurchaseListSection(controller),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipListRows(MembershipController controller) {
    bool isMobile = Responsive.isMobile(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth = constraints.maxWidth > 750
            ? constraints.maxWidth
            : 750;
        return CustomHorizontalScrollbar(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    // Column Headers
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!),
                          bottom: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Checkbox(
                              value:
                                  controller.selectedMembershipIds.isNotEmpty &&
                                  controller.selectedMembershipIds.length ==
                                      controller.filteredMemberships.length,
                              onChanged: (v) =>
                                  controller.toggleAllMemberships(),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          Expanded(
                            flex: isMobile ? 4 : 3,
                            child: const Text(
                              "MEMBERSHIP",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          if (!isMobile)
                            const Expanded(
                              flex: 1,
                              child: Text(
                                "VALID FOR",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          if (!isMobile)
                            const Expanded(
                              flex: 1,
                              child: Text(
                                "SESSIONS",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          if (!isMobile)
                            const Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  "FREQUENCY",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            flex: isMobile ? 2 : 1,
                            child: const Text(
                              "PRICE",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: isMobile ? 2 : 1,
                            child: const Text(
                              "ACTIONS",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List Items
                    if (controller.filteredMemberships.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text("No memberships found")),
                      )
                    else
                      ...controller.filteredMemberships.map((membership) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Checkbox(
                                  value: controller.selectedMembershipIds
                                      .contains(membership.id),
                                  onChanged: (v) => controller
                                      .toggleMembershipSelection(membership.id),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              Expanded(
                                flex: isMobile ? 4 : 3,
                                child: Row(
                                  children: [
                                    Container(
                                      width: isMobile ? 50 : 85,
                                      height: isMobile ? 50 : 85,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRed.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          membership.name
                                                  .toLowerCase()
                                                  .contains("silver")
                                              ? AppIcons.silverMembership
                                              : membership.name
                                                    .toLowerCase()
                                                    .contains("gold")
                                              ? AppIcons.goldMembership
                                              : membership.name
                                                    .toLowerCase()
                                                    .contains("platinum")
                                              ? AppIcons.platinumMembership
                                              : AppIcons.memberships,
                                          width: isMobile ? 30 : 50,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            membership.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: isMobile ? 13 : 14,
                                              color: AppColors.softBlack,
                                            ),
                                          ),
                                          Text(
                                            "${membership.servicesCount} services${isMobile ? " • ${membership.frequency} • ${membership.sessions}" : ""}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          if (isMobile)
                                            Text(
                                              membership.isRecurring
                                                  ? "Recurring"
                                                  : "One-time",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 11,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isMobile)
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    membership.isRecurring
                                        ? "Recurring"
                                        : "One-time",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              if (!isMobile)
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "${membership.sessions} session every month",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              if (!isMobile)
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      membership.frequency,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              Expanded(
                                flex: isMobile ? 2 : 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text(
                                      "£",
                                      style: TextStyle(
                                        color: AppColors.primaryRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      " ${membership.price.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isMobile ? 13 : 14,
                                        color: AppColors.softBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: isMobile ? 2 : 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Consumer<ServicesController>(
                                      builder:
                                          (context, servicesController, child) {
                                            return IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              onPressed: () =>
                                                  controller.setAdding(
                                                    true,
                                                    membership: membership,
                                                    allServices:
                                                        servicesController
                                                            .services
                                                            .cast<Service>(),
                                                  ),
                                              icon: SvgPicture.asset(
                                                AppIcons.edit,
                                                width: 16,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                      AppColors.primaryRed,
                                                      BlendMode.srcIn,
                                                    ),
                                              ),
                                            );
                                          },
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              "Delete Membership",
                                            ),
                                            content: const Text(
                                              "Are you sure you want to delete this membership?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  controller.deleteMembership(
                                                    membership.id,
                                                  );
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                    color: AppColors.primaryRed,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: SvgPicture.asset(
                                        AppIcons.trash,
                                        width: 20,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.primaryRed,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  DateTime? _parseDateSafely(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    String clean = dateStr.trim();
    try {
      // Append Z to parse as UTC, then convert to local
      return DateTime.parse("${clean.replaceFirst(' ', 'T')}Z").toLocal();
    } catch (_) {
      try {
        final parts = clean.split(' ');
        if (parts.length >= 3) {
          final d = parts[0].split('-');
          final t = parts[1].split(':');
          int h = int.parse(t[0]);
          if (parts[2].toUpperCase() == 'PM' && h < 12) h += 12;
          if (parts[2].toUpperCase() == 'AM' && h == 12) h = 0;
          return DateTime.utc(
            int.parse(d[0]),
            int.parse(d[1]),
            int.parse(d[2]),
            h,
            int.parse(t[1]),
            t.length > 2 ? int.parse(t[2]) : 0,
          ).toLocal();
        }
      } catch (_) {}
    }
    return null;
  }

  int _getCurrentTier(String membershipName) {
    final lower = membershipName.toLowerCase();
    if (lower.contains('platinum')) return 3;
    if (lower.contains('gold')) return 2;
    if (lower.contains('silver')) return 1;
    return 0;
  }

  String _getTierName(int tier) {
    switch (tier) {
      case 1:
        return "Silver";
      case 2:
        return "Gold";
      case 3:
        return "Platinum";
      default:
        return "";
    }
  }

  String _formatDate(String dateStr) {
    final dt = _parseDateSafely(dateStr);
    if (dt != null) {
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    }
    return dateStr.split(' ').first;
  }

  String _formatTime(String dateStr) {
    final dt = _parseDateSafely(dateStr);
    if (dt != null) {
      final hour = dt.hour;
      final min = dt.minute.toString().padLeft(2, '0');
      final sec = dt.second.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = (hour % 12 == 0 ? 12 : hour % 12)
          .toString()
          .padLeft(2, '0');
      return "$formattedHour:$min:$sec $period";
    }
    final parts = dateStr.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : "";
  }

  String _getTimeRemaining(String? displayConfirmedAt) {
    final dt = _parseDateSafely(displayConfirmedAt);
    if (dt == null) return "N/A";

    final expiry = dt.add(const Duration(days: 30));
    final now = DateTime.now();
    final diff = expiry.difference(now);

    if (diff.isNegative) {
      return "Expired";
    } else {
      final days = diff.inDays;
      final hours = diff.inHours % 24;
      return "${days}d ${hours}h";
    }
  }

  Widget _buildPurchaseListSection(MembershipController controller) {
    bool isMobile = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Membership Purchases",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.softBlack,
                fontFamily: 'Libre',
              ),
            ),
            Container(
              height: 40,
              width: 250,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: controller.purchaseSearchController,
                onChanged: (value) => controller.setPurchaseSearchQuery(value),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.softBlack,
                ),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                  hintText: "Search purchases...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(bottom: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final double tableWidth = constraints.maxWidth > 800
                ? constraints.maxWidth
                : 800;
            return CustomHorizontalScrollbar(
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          // Column Headers
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[200]!),
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    "MEMBERSHIP",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                if (!isMobile)
                                  const Expanded(
                                    flex: 2,
                                    child: Text(
                                      "CUSTOMER",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                if (!isMobile)
                                  const Expanded(
                                    flex: 1,
                                    child: Text(
                                      "PAYMENT",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                if (!isMobile)
                                  const Expanded(
                                    flex: 1,
                                    child: Text(
                                      "DATE",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                if (!isMobile)
                                  const Expanded(
                                    flex: 1,
                                    child: Text(
                                      "TIME PERIOD",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                const Expanded(
                                  flex: 1,
                                  child: Text(
                                    "STATUS",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 1,
                                  child: Text(
                                    "ACTIONS",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Items
                          if (controller.filteredPurchases.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(48.0),
                              child: Center(
                                child: Text(
                                  controller.purchaseError ??
                                      "No membership purchases found",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: controller.purchaseError != null
                                        ? AppColors.primaryRed
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.filteredPurchases.length,
                              itemBuilder: (context, index) {
                                final purchase =
                                    controller.filteredPurchases[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color:
                                            index ==
                                                controller
                                                        .filteredPurchases
                                                        .length -
                                                    1
                                            ? Colors.transparent
                                            : Colors.grey[200]!,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              purchase.membershipName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: AppColors.softBlack,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  "£",
                                                  style: TextStyle(
                                                    color: AppColors.primaryRed,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  " ${purchase.price.toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (isMobile) ...[
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  _buildUserAvatar(
                                                    imageUrl:
                                                        purchase.userImage,
                                                    name:
                                                        purchase.userName ??
                                                        "?",
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      purchase.userName ??
                                                          "Unknown User",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey[600],
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (!isMobile)
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              _buildUserAvatar(
                                                imageUrl: purchase.userImage,
                                                name: purchase.userName ?? "?",
                                                size: 28,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      purchase.userName ??
                                                          "Guest User",
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors.softBlack,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      purchase.userPhone ??
                                                          "Unknown",
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (!isMobile)
                                        Expanded(
                                          flex: 1,
                                          child: Row(
                                            children: [
                                              Text(
                                                purchase.paymentMethod,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              if (purchase.paymentProof !=
                                                      null &&
                                                  purchase.paymentProof
                                                      .toString()
                                                      .trim()
                                                      .isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                InkWell(
                                                  onTap: () =>
                                                      _showPaymentProofDialog(
                                                        context,
                                                        purchase,
                                                      ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .primaryRed
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: SvgPicture.asset(
                                                      AppIcons.bank,
                                                      width: 14,
                                                      colorFilter:
                                                          const ColorFilter.mode(
                                                            AppColors
                                                                .primaryRed,
                                                            BlendMode.srcIn,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      if (!isMobile)
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _formatDate(purchase.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.softBlack,
                                                ),
                                              ),
                                              Text(
                                                _formatTime(purchase.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (!isMobile)
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _getTimeRemaining(
                                                  purchase.displayConfirmedAt,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryRed,
                                                ),
                                              ),
                                              const Text(
                                                "Remaining",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: _buildPurchaseStatusBadge(
                                            purchase.status,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            (() {
                                              int currentTier = _getCurrentTier(
                                                purchase.membershipName,
                                              );
                                              int targetTier =
                                                  purchase.isUpgraded;

                                              if (targetTier > 0 &&
                                                  targetTier != currentTier) {
                                                bool isUpgrade =
                                                    targetTier > currentTier;
                                                String actionText = isUpgrade
                                                    ? "Upgrade to ${_getTierName(targetTier)}"
                                                    : "Downgrade to ${_getTierName(targetTier)}";
                                                IconData actionIcon = isUpgrade
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward;
                                                Color actionColor = isUpgrade
                                                    ? AppColors.primaryRed
                                                    : AppColors.softBlack;
                                                Color bgColor = isUpgrade
                                                    ? AppColors.primaryRed
                                                          .withValues(
                                                            alpha: 0.1,
                                                          )
                                                    : Colors.grey[100]!;

                                                return Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        controller
                                                            .changePurchasePlan(
                                                              purchase.id,
                                                              targetTier,
                                                            );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: bgColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              actionIcon,
                                                              size: 12,
                                                              color:
                                                                  actionColor,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              actionText,
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    actionColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                  ],
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            })(),
                                            if (purchase.status.toLowerCase() ==
                                                "pending") ...[
                                              buildActionIcon(
                                                svgPath: AppIcons.confirmed,
                                                color: AppColors.grey,
                                                onTap: () async {
                                                  final message =
                                                      await controller
                                                          .updatePurchaseStatus(
                                                            purchase.id,
                                                            "confirmed",
                                                          );
                                                  final isError = message
                                                      .startsWith("Error");
                                                  if (context.mounted) {
                                                    SnackBarUtils.showSnackBar(
                                                      context,
                                                      message,
                                                      isError: isError,
                                                    );
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 12),
                                              buildActionIcon(
                                                svgPath: AppIcons.cross,
                                                color: AppColors.grey,
                                                onTap: () async {
                                                  final message =
                                                      await controller
                                                          .updatePurchaseStatus(
                                                            purchase.id,
                                                            "rejected",
                                                          );
                                                  final isError = message
                                                      .startsWith("Error");
                                                  if (context.mounted) {
                                                    SnackBarUtils.showSnackBar(
                                                      context,
                                                      message,
                                                      isError: isError,
                                                    );
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 12),
                                            ],
                                            buildActionIcon(
                                              svgPath: AppIcons.cancel,
                                              color: AppColors.primaryRed,
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text(
                                                      "Delete Purchase",
                                                    ),
                                                    content: const Text(
                                                      "Are you sure you want to permanently delete this purchase?",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text(
                                                          "Cancel",
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          controller
                                                              .deletePurchase(
                                                                purchase.id,
                                                              );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: const Text(
                                                          "Delete",
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .primaryRed,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPurchaseStatusBadge(String? status) {
    final effectiveStatus = status ?? "pending";
    Color color;
    switch (effectiveStatus.toLowerCase()) {
      case 'confirmed':
        color = AppColors.primaryRed;
        break;
      case 'rejected':
        color = AppColors.primaryRed;
        break;
      case 'pending':
      default:
        color = AppColors.grey;
        break;
    }

    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Text(
          effectiveStatus.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  void _showPaymentProofDialog(
    BuildContext context,
    MembershipPurchaseModel purchase,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Payment Proof",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Libre',
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Image content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppNetworkImage(
                    imageUrl: purchase.paymentProofUrl,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => SizedBox(
                      height: 350,
                      child: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: AppColors.primaryRed,
                          size: 30,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 350,
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Payment Proof not available",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Footer info
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            purchase.membershipName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.softBlack,
                            ),
                          ),
                          Text(
                            "Amount: £${purchase.price.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPurchaseStatusBadge(purchase.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipForm(MembershipController controller) {
    bool isMobile = Responsive.isMobile(context);
    return Column(
      children: [
        // FIXED HEADER SECTION
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  controller.editingMembership != null
                      ? "Edit membership"
                      : "Add membership",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.softBlack,
                    fontFamily: 'Libre',
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.setAdding(false),
                  icon: SvgPicture.asset(
                    AppIcons.cross,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: const Text("Close Form"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // SCROLLABLE FORM SECTION
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              if (isMobile) ...[
                _buildBasicInfoSection(controller),
                const SizedBox(height: 24),
                _buildPricingSection(controller),
                const SizedBox(height: 24),
                _buildServicesSection(controller),
                const SizedBox(height: 24),
                _buildTermsSection(controller),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildBasicInfoSection(controller),
                          const SizedBox(height: 24),
                          _buildPricingSection(controller),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _buildServicesSection(controller),
                          const SizedBox(height: 24),
                          _buildTermsSection(controller),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  buildFormActionButtons(
                    onSave: () async {
                      final success = await controller.saveMembership();
                      if (mounted && success) {
                        controller.setAdding(false);
                      }
                    },
                    onDiscard: () {
                      controller.setAdding(false);
                      controller.clearForm();
                    },
                    isLoading: controller.isLoading,
                    saveText: controller.editingMembership != null
                        ? "Save changes"
                        : "Create membership",
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(MembershipController controller) {
    return _buildSection(
      title: "Basic info",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Membership name"),
          _buildTextField(
            controller.nameController,
            "e.g. Silver Membership",
            hint: "Enter membership name",
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel("Membership description"),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller.descriptionController,
                builder: (context, value, child) {
                  return Text(
                    "${value.text.length}/360",
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  );
                },
              ),
            ],
          ),
          _buildTextField(
            controller.descriptionController,
            "Describe the membership",
            hint: "Provide details about what includes in this membership...",
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(MembershipController controller) {
    bool isMobile = Responsive.isMobile(context);
    return _buildSection(
      title: "Services and sessions",
      subtitle: "Add the services and sessions included in the membership.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Included services"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${controller.selectedServiceIds.length} services",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.softBlack,
                  ),
                ),
                TextButton(
                  onPressed: () => controller.toggleServicesList(),
                  child: Text(
                    controller.showServicesList ? "Close" : "Edit",
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (controller.showServicesList) ...[
            const SizedBox(height: 16),
            // FILTER SECTION: Search and Category
            Consumer<CategoryController>(
              builder: (context, catController, child) {
                final categories =
                    ["All Categories"] +
                    catController.categories.map((c) => c.title).toList();

                return Column(
                  children: [
                    Row(
                      children: [
                        // Search Services
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller.servicesSearchController,
                            "Search services...",
                            hint: "Search by name...",
                            onChanged: (val) =>
                                controller.setServicesSearchQuery(val),
                            prefix: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SvgPicture.asset(
                                AppIcons.search,
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.grey,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Category Dropdown
                        Expanded(
                          flex: 2,
                          child: _buildDropdown(
                            categories,
                            controller.selectedServicesCategory ??
                                "All Categories",
                            onChanged: (val) =>
                                controller.setSelectedServicesCategory(
                                  val == "All Categories" ? null : val,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),

            Container(
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Consumer<ServicesController>(
                builder: (context, servicesController, child) {
                  final allServices = servicesController.services;
                  final filteredServices = allServices.where((s) {
                    final matchesCategory =
                        controller.selectedServicesCategory == null ||
                        s.category == controller.selectedServicesCategory;
                    final matchesSearch =
                        controller.servicesSearchQuery.isEmpty ||
                        s.name.toLowerCase().contains(
                          controller.servicesSearchQuery.toLowerCase(),
                        );
                    return matchesCategory && matchesSearch;
                  }).toList();

                  if (allServices.isEmpty && servicesController.isLoading) {
                    return Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: AppColors.primaryRed,
                        size: 20,
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredServices.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 0.1, thickness: 0.2),
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      final isSelected = controller.selectedServiceIds.contains(
                        service.id,
                      );
                      return ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[200],
                            image:
                                (service.image != null &&
                                    service.image!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(
                                      ApiService.getImageUrl(service.image),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              (service.image == null || service.image!.isEmpty)
                              ? const Icon(
                                  Icons.image,
                                  size: 20,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        title: Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.softBlack,
                          ),
                        ),
                        subtitle: Text(
                          "£${service.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (val) =>
                              controller.toggleServiceSelection(service.id),
                        ),
                        onTap: () =>
                            controller.toggleServiceSelection(service.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
          if (controller.selectedServiceIds.isNotEmpty) ...[
            const SizedBox(height: 16),
            Consumer<ServicesController>(
              builder: (context, servicesController, child) {
                final selectedServices = servicesController.services
                    .where((s) => controller.selectedServiceIds.contains(s.id))
                    .toList();
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedServices.map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            service.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.softBlack,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                controller.toggleServiceSelection(service.id),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
          const SizedBox(height: 24),
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Sessions"),
                    _buildDropdown(
                      ["Limited", "Unlimited"],
                      controller.selectedSessionsType,
                      onChanged: (val) => controller.setSessionsType(val!),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 24 : 0),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Number of sessions"),
                    _buildTextField(
                      controller.sessionsController,
                      "0",
                      hint: "Enter number of sessions",
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "For recurring memberships, the number of sessions will renew at the beginning of each payment cycle.",
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(MembershipController controller) {
    bool isMobile = Responsive.isMobile(context);
    return _buildSection(
      title: "Pricing and payment",
      subtitle: "Choose how you'd like your clients to pay.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                flex: isMobile ? 0 : 1,
                child: _buildPaymentTypeCard(
                  title: "One-time payment",
                  subtitle: "Clients are charged once at the time of purchase.",
                  isSelected: !controller.isRecurring,
                  onTap: () => controller.setIsRecurring(false),
                ),
              ),
              SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: _buildPaymentTypeCard(
                  title: "Recurring payments",
                  subtitle: "Clients are charged on the renewal date.",
                  isSelected: controller.isRecurring,
                  onTap: () => controller.setIsRecurring(true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Payment frequency & length"),
                    _buildDropdown(
                      [
                        "Monthly (Until canceled)",
                        "Monthly (Fixed period)",
                        "Yearly (Until canceled)",
                        "Yearly (Fixed period)",
                      ],
                      controller.selectedFrequency,
                      onChanged: (val) => controller.setFrequency(val!),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 24 : 0),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Recurring price"),
                    _buildTextField(
                      controller.priceController,
                      "0.00",
                      hint: "0.00",
                      prefix: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          "£",
                          style: TextStyle(
                            color: AppColors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(MembershipController controller) {
    return _buildSection(
      title: "Terms & Conditions",
      subtitle:
          "If there are any rules attached to your membership it's a good place to mention them.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel("Terms & Conditions", isOptional: true),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller.termsController,
                builder: (context, value, child) {
                  return Text(
                    "${value.text.length}/3000",
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  );
                },
              ),
            ],
          ),
          _buildTextField(
            controller.termsController,
            "Enter terms and conditions",
            hint: "Enter any special terms or conditions here...",
            maxLines: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.softBlack,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: AppColors.grey),
            ),
          ],
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.softBlack,
          ),
          children: isOptional
              ? [
                  const TextSpan(
                    text: " (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: AppColors.grey,
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelHint, {
    String? hint,
    int maxLines = 1,
    Widget? prefix,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
      decoration: InputDecoration(
        hintText: hint ?? labelHint,
        hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
        prefixIcon: prefix,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String value, {
    ValueChanged<String?>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[400],
            size: 24,
          ),
          style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
          dropdownColor: Colors.white,
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPaymentTypeCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100, // Fixed height for balance
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryRed.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.softBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primaryRed,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar({
    String? imageUrl,
    required String name,
    double size = 24,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[200]!, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? AppNetworkImage(
              imageUrl: ApiService.getImageUrl(imageUrl),
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.primaryRed,
                  size: size * 0.5,
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.45,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.45,
                ),
              ),
            ),
    );
  }
}
