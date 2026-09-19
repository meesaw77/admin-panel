import 'package:admin/controllers/bookings/bookings_controller.dart';
import 'package:admin/models/booking_model.dart';
import 'package:admin/responsive.dart';
import 'package:admin/services/api_service.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../utils/bulk_delete.dart';
import '../../utils/snack_bar_utils.dart';
import '../../utils/confirmed_delete.dart';
import '../../widgets/icon_button.dart';
import 'package:admin/widgets/custom_horizontal_scrollbar.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late BookingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<BookingsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.fetchBookings();
        _controller.startPolling();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = context.read<BookingsController>();
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
      body: Consumer<BookingsController>(
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
                _buildTabSelector(controller),
                const SizedBox(height: 24),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchBookings(),
                    color: AppColors.primaryRed,
                    child: Scrollbar(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildListHeader(context, controller),
                          const SizedBox(height: 16),
                          _buildBookingsList(context, controller),
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

  Widget _buildHeaderTitle(BookingsController controller) {
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
              "Bookings Management",
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
          "Review and manage client appointments",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector(BookingsController controller) {
    return Row(
      children: [
        _buildTabItem(controller, "Bookings"),
        const SizedBox(width: 12),
        _buildTabItem(controller, "Completed"),
        const SizedBox(width: 12),
        _buildTabItem(controller, "Rejected/Canceled"),
      ],
    );
  }

  Widget _buildTabItem(BookingsController controller, String title) {
    final bool isSelected = controller.selectedTab == title;
    return InkWell(
      onTap: () => controller.setSelectedTab(title),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryRed
                : AppColors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.softBlack.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSearch(BookingsController controller) {
    return SizedBox(
      width: 320,
      height: 45,
      child: TextField(
        onChanged: (value) => controller.setSearchQuery(value),
        style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
        decoration: InputDecoration(
          hintText: "Search by client or service...",
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
            borderSide: BorderSide(
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    Color textColor = Colors.white;
    switch (status?.toLowerCase()) {
      case 'confirmed':
      case 'completed':
      case 'approved':
        color = AppColors.primaryRed;
        break;
      case 'pending':
      case 'waiting':
        color = AppColors.grey;
        break;
      case 'cancelled':
      case 'rejected':
      default:
        color = AppColors.grey.withValues(alpha: 0.2);
        textColor = AppColors.softBlack;
    }

    return Container(
      width: 85,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          status ?? "Unknown",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, BookingsController controller) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "${controller.selectedTab == "Bookings"
                ? "Total Bookings"
                : controller.selectedTab == "Completed"
                ? "Total Completed"
                : "Total Rejected/Canceled"}: ${controller.filteredBookings.length}",
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
                itemNamePlural: "bookings",
                onConfirm: () async {
                  final error = await controller.bulkDelete(controller.selectedIds);
                  if (context.mounted) {
                    if (error != null) {
                      SnackBarUtils.showSnackBar(context, error, isError: true);
                    } else {
                      SnackBarUtils.showSnackBar(context, "Bookings deleted successfully");
                    }
                  }
                },
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
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            label: Text("Delete Selected (${controller.selectedIds.length})"),
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

  Widget _buildBookingsList(
    BuildContext context,
    BookingsController controller,
  ) {
    if (controller.isLoading && controller.bookings.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: AppColors.primaryRed,
            size: 30,
          ),
        ),
      );
    }

    if (controller.bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.booking,
                width: 80,
                colorFilter: ColorFilter.mode(
                  AppColors.softBlack.withValues(alpha: 0.1),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "No bookings found",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double tableWidth = constraints.maxWidth > 850
            ? constraints.maxWidth
            : 850;
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
                          value:
                              controller.selectedIds.length ==
                                  controller.filteredBookings.length &&
                              controller.filteredBookings.isNotEmpty,
                          onChanged: (val) =>
                              controller.selectAll(val ?? false),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: _buildTableHeaderText("Client Name"),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildTableHeaderText("Service"),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildTableHeaderText("Date & Time"),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildTableHeaderText("Staff"),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildTableHeaderText("Duration"),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildTableHeaderText("Points"),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildTableHeaderText("Price"),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildTableHeaderText("Payment"),
                        ),
                        Expanded(flex: 2, child: _buildTableHeaderText("Type")),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _buildTableHeaderText("Status"),
                          ),
                        ),
                        Expanded(
                          flex: 2,
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
                  Divider(height: 1, thickness: 1.0, color: Colors.grey[200]),
                  // List Items
                  Column(
                    children: List.generate(controller.filteredBookings.length, (
                      index,
                    ) {
                      final Booking booking =
                          controller.filteredBookings[index];
                      bool isSelected = controller.selectedIds.contains(
                        booking.id,
                      );
                      return Column(
                        children: [
                          InkWell(
                            onTap: () => controller.toggleSelection(booking.id),
                            hoverColor: AppColors.primaryRed.withValues(
                              alpha: 0.05,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (val) =>
                                        controller.toggleSelection(booking.id),
                                  ),
                                  const SizedBox(width: 8),
                                  // Client Info
                                  Expanded(
                                    flex: 3,
                                    child: InkWell(
                                      onTap: () => _showUserDetailsDialog(context, booking),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Row(
                                        children: [
                                        _buildAvatar(
                                          imageUrl: booking.userProfileImage,
                                          userName:
                                              booking.username ?? "Client",
                                          size: 40,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "CLIENT",
                                                style: TextStyle(
                                                  color: AppColors.primaryRed
                                                      .withValues(alpha: 0.8),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                booking.username ??
                                                    "Unknown Client",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: AppColors.softBlack,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    ),
                                  ),
                                  // Service
                                  Expanded(
                                    flex: 2,
                                    child: Builder(
                                      builder: (context) {
                                        final services =
                                            (booking.serviceName ?? "")
                                                .split(',')
                                                .where(
                                                  (s) => s.trim().isNotEmpty,
                                                )
                                                .toList();

                                        if (services.length > 1) {
                                          return InkWell(
                                            onTap: () => _showServicesDialog(
                                              context,
                                              services,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "${services.length} Services",
                                                    style: const TextStyle(
                                                      color: AppColors.grey,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Satoshi',
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.info_outline_rounded,
                                                    size: 14,
                                                    color: AppColors.grey,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        return Text(
                                          booking.serviceName ??
                                              "General Service",
                                          style: const TextStyle(
                                            color: AppColors.grey,
                                            fontSize: 13,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Date & Time
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              AppIcons.booking,
                                              width: 14,
                                              height: 14,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    AppColors.primaryRed,
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              booking.date ?? "No date",
                                              style: const TextStyle(
                                                color: AppColors.softBlack,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (booking.time != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16,
                                            ),
                                            child: Text(
                                              _formatTime12h(booking.time!),
                                              style: const TextStyle(
                                                color: AppColors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Staff
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      booking.staffName ?? "Unassigned",
                                      style: const TextStyle(
                                        color: AppColors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  // Duration
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        if (booking.duration != null &&
                                            booking.duration!.isNotEmpty) ...[
                                          SvgPicture.asset(
                                            AppIcons.duration,
                                            width: 18,
                                            height: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            booking.duration!
                                                        .toLowerCase()
                                                        .contains('m') ||
                                                    booking.duration!
                                                        .toLowerCase()
                                                        .contains('h')
                                                ? booking.duration!
                                                : "${booking.duration} min",
                                            style: const TextStyle(
                                              color: AppColors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ] else
                                          const Text(
                                            "--",
                                            style: TextStyle(
                                              color: AppColors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Points
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          AppIcons.badge,
                                          width: 18,
                                          height: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          booking.loyaltyPoints ?? "0",
                                          style: const TextStyle(
                                            color: AppColors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Price
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        if (booking.price != null) ...[
                                          SvgPicture.asset(
                                            AppIcons.pound,
                                            width: 14,
                                            height: 14,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.primaryRed,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${booking.price}",
                                            style: const TextStyle(
                                              color: AppColors.grey,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ] else
                                          const Text(
                                            "--",
                                            style: TextStyle(
                                              color: AppColors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Payment Column
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      booking.paymentMethod ?? "Cash",
                                      style: const TextStyle(
                                        color: AppColors.grey,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  // Appointment Type
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      booking.appointmentType ?? "--",
                                      style: const TextStyle(
                                        color: AppColors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  // Status
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (booking.paymentProof != null &&
                                            booking.paymentProof!.isNotEmpty) ...[
                                          InkWell(
                                            onTap: () => _showPaymentProof(
                                              context,
                                              booking,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryRed
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Icon(
                                                Icons.image_outlined,
                                                size: 14,
                                                color: AppColors.primaryRed,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        _buildStatusBadge(booking.status),
                                      ],
                                    ),
                                  ),
                                  // Actions
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (booking.status.toLowerCase() ==
                                                "pending" ||
                                            booking.status.toLowerCase() ==
                                                "waiting") ...[
                                          buildActionIcon(
                                            svgPath: AppIcons.confirmed,
                                            color: AppColors.grey,
                                            onTap: () async {
                                              final message = await controller
                                                  .updateBookingStatus(
                                                    booking.id,
                                                    "Confirmed",
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
                                            svgPath: AppIcons.cancel,
                                            color: AppColors.grey,
                                            onTap: () async {
                                              final message = await controller
                                                  .updateBookingStatus(
                                                    booking.id,
                                                    "Rejected",
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
                                        ] else if (booking.status
                                                .toLowerCase() ==
                                            "confirmed") ...[
                                          buildActionIcon(
                                            svgPath: AppIcons.confirmed,
                                            color: AppColors.primaryRed,
                                            onTap: () async {
                                              final message = await controller
                                                  .updateBookingStatus(
                                                    booking.id,
                                                    "Completed",
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
                                        ] else ...[
                                          buildActionIcon(
                                            svgPath: AppIcons.trash,
                                            color: AppColors.grey,
                                            onTap: () => showDeleteConfirm(
                                              context: context,
                                              message:
                                                  "Are you sure you want to delete this booking ?",
                                              onDelete: () async {
                                                final error = await controller
                                                    .deleteBooking(booking.id);
                                                if (context.mounted) {
                                                  if (error != null) {
                                                    SnackBarUtils.showSnackBar(
                                                      context,
                                                      error,
                                                      isError: true,
                                                    );
                                                  } else {
                                                    SnackBarUtils.showSnackBar(
                                                      context,
                                                      "Booking deleted successfully",
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (index < controller.filteredBookings.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1.0,
                              color: AppColors.grey.withValues(alpha: 0.4),
                            ),
                        ],
                      );
                    }),
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

  Widget _buildAvatar({
    String? imageUrl,
    required String userName,
    double size = 40,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
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

  void _showPaymentProof(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Payment Proof",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.softBlack,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppNetworkImage(
                  imageUrl: ApiService.getImageUrl(booking.paymentProof!),
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    height: 350,
                    alignment: Alignment.center,
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.primaryRed,
                      size: 30,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 350,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Payment Proof not available",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.payment,
                    size: 16,
                    color: AppColors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking.paymentMethod ?? "Bank Transfer",
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Satoshi'
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime12h(String time24) {
    try {
      if (time24.isEmpty) return "--";

      // Handle cases like "15:0" -> "15:00"
      if (time24.contains(':')) {
        final parts = time24.split(':');
        if (parts[1].length == 1) {
          time24 = "${parts[0]}:0${parts[1]}";
        } else if (parts[1].isEmpty) {
          time24 = "${parts[0]}:00";
        }
      }

      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      final period = hour >= 12 ? "PM" : "AM";
      hour = hour % 12;
      if (hour == 0) hour = 12;

      final minuteStr = minute.toString().padLeft(2, '0');
      return "$hour:$minuteStr $period";
    } catch (e) {
      return time24;
    }
  }

  void _showUserDetailsDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(
                  imageUrl: booking.userProfileImage,
                  userName: booking.username ?? "Client",
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  booking.username ?? "Unknown Client",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.softBlack,
                    fontFamily: 'Libre',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_outlined, size: 20, color: AppColors.softBlack),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Phone Number", style: TextStyle(fontSize: 12, color: AppColors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            booking.userPhone != null && booking.userPhone!.isNotEmpty ? booking.userPhone! : "Not provided",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.softBlack),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.email_outlined, size: 20, color: AppColors.softBlack),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Email Address", style: TextStyle(fontSize: 12, color: AppColors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            booking.userEmail != null && booking.userEmail!.isNotEmpty ? booking.userEmail! : "Not provided",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.softBlack),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showServicesDialog(BuildContext context, List<String> services) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Booked Services",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.softBlack,
                    fontFamily: 'Libre',
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: services.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              services[index].trim(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.softBlack,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
