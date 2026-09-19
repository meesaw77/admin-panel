import 'package:admin/controllers/auth_controller.dart';
import 'package:admin/controllers/bookings/bookings_controller.dart';
import 'package:admin/controllers/navigation_controller.dart';
import 'package:admin/services/api_service.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class UserProfileHeader extends StatefulWidget {
  final bool isNarrow;
  final bool isDark;

  const UserProfileHeader({
    super.key,
    this.isNarrow = false,
    this.isDark = true,
  });

  @override
  State<UserProfileHeader> createState() => _UserProfileHeaderState();
}

class _UserProfileHeaderState extends State<UserProfileHeader> {
  final _overlayController = OverlayPortalController();
  final _layerLink = LayerLink();

  void _closeDrawerIfOpen(BuildContext context) {
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isDark
        ? AppColors.white
        : AppColors.softBlack;
    final Color subTextColor = widget.isDark
        ? AppColors.white.withValues(alpha: 0.5)
        : AppColors.softBlack.withValues(alpha: 0.5);
    final Color iconColor = widget.isDark
        ? AppColors.white
        : AppColors.softBlack;

    return Consumer<AuthController>(
      builder: (context, auth, child) {
        final user = auth.currentUser;

        Widget buildAvatar(double radius) {
          final imageUrl = user?.image != null
              ? ApiService.getImageUrl(user!.image)
              : "";
          final bool hasImage = user?.image != null && user!.image!.isNotEmpty;

          if (hasImage) {
            return ClipOval(
              child: AppNetworkImage(
                imageUrl: imageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircleAvatar(
                  radius: radius,
                  backgroundColor: AppColors.primaryRed,
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: radius,
                  backgroundColor: AppColors.primaryRed,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: radius * 0.9,
                    ),
                  ),
                ),
              ),
            );
          }
          return CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.primaryRed,
            child: Text(
              user != null && user.name.isNotEmpty
                  ? user.name[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.9,
              ),
            ),
          );
        }

        // 1. NARROW MODE (Icon Only)
        if (widget.isNarrow) {
          return buildAvatar(18);
        }

        // 2. WIDE MODE (Full Profile)
        return Row(
          children: [
            // 1. Avatar
            buildAvatar(20),
            const SizedBox(width: 12),

            // 2. Name & Role
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? "Admin User",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Libre',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user?.role != null)
                    Text(
                      user!.role.toUpperCase(),
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        fontFamily: 'Satoshi',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 3. Notification Bell (Pushed to Right)
            CompositedTransformTarget(
              link: _layerLink,
              child: Consumer<BookingsController>(
                builder: (context, bookings, child) {
                  return OverlayPortal(
                    controller: _overlayController,
                    overlayChildBuilder: (context) {
                      return Stack(
                        children: [
                          // Dismissible Barrier
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () => _overlayController.hide(),
                              behavior: HitTestBehavior.translucent,
                            ),
                          ),
                          // Dropdown
                          CompositedTransformFollower(
                            link: _layerLink,
                            targetAnchor: Alignment.bottomRight,
                            followerAnchor: Alignment.topLeft,
                            offset: const Offset(0, 12),
                            child: Material(
                              color: Colors.transparent,
                              child: _buildNotificationDropdown(
                                context,
                                bookings,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () {
                            _overlayController.toggle();
                          },
                          icon: SvgPicture.asset(
                            AppIcons.bell,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        if (bookings.hasUnseenBookings)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryRed,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 8,
                                minHeight: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationDropdown(
    BuildContext context,
    BookingsController bookings,
  ) {
    final pendingBookings = bookings.roleFilteredPendingBookings
        .take(5)
        .toList();

    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.softBlack,
                    fontFamily: 'Libre',
                    letterSpacing: -0.5,
                  ),
                ),
                if (bookings.hasUnseenBookings)
                  GestureDetector(
                    onTap: () {
                      bookings.markBookingsAsSeen();
                      _overlayController.hide();
                    },
                    child: Text(
                      "Mark all as read",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryRed.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 0.5, thickness: 0.5),

          // --- CONTENT ---
          if (pendingBookings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 32,
                        color: AppColors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "All Caught Up!",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.softBlack,
                        fontFamily: 'Libre',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "You have no new notifications at the moment.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.grey.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: pendingBookings.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 0.5, thickness: 0.3),
                itemBuilder: (context, index) {
                  final booking = pendingBookings[index];
                  return InkWell(
                    onTap: () {
                      Provider.of<NavigationController>(
                        context,
                        listen: false,
                      ).setSelectedByTitle("Appointments");
                      _overlayController.hide();
                      _closeDrawerIfOpen(context);
                    },
                    hoverColor: AppColors.primaryRed.withValues(alpha: 0.03),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- AVATAR / ICON ---
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryRed.withValues(
                                  alpha: 0.06,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child:
                                  booking.userProfileImage != null &&
                                      booking.userProfileImage!.isNotEmpty
                                  ? AppNetworkImage(
                                      imageUrl: booking.userProfileImage!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: AppColors.grey.withValues(
                                          alpha: 0.05,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: AppColors.primaryRed
                                                .withValues(alpha: 0.03),
                                            child: const Icon(
                                              Icons.person_outline_rounded,
                                              size: 24,
                                              color: AppColors.primaryRed,
                                            ),
                                          ),
                                    )
                                  : Container(
                                      color: AppColors.primaryRed.withValues(
                                        alpha: 0.03,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          AppIcons.booking,
                                          width: 20,
                                          height: 20,
                                          colorFilter: const ColorFilter.mode(
                                            AppColors.primaryRed,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // --- TEXT CONTENT ---
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        booking.username ?? "Unknown Client",
                                        style: const TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.softBlack,
                                          fontFamily: 'Libre',
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRed.withValues(
                                          alpha: 0.06,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: const Text(
                                        "NEW",
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primaryRed,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  booking.serviceName ?? "Service Request",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.softBlack.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Satoshi',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey.withValues(
                                      alpha: 0.03,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        AppIcons.duration,
                                        width: 18,
                                        height: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${booking.date ?? 'N/A'} • ${booking.time ?? ''}",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.grey.withValues(
                                            alpha: 0.6,
                                          ),
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Satoshi',
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
