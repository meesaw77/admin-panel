import 'package:admin/controllers/bookings/bookings_controller.dart';
import 'package:admin/models/booking_model.dart';
import 'package:admin/screens/dashboard/components/storage_info_card.dart';
import 'package:admin/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/theme/layout.dart';
import 'package:intl/intl.dart';

class StorageDetails extends StatelessWidget {
  const StorageDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingsController>().bookings;
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    // Filter for TODAY'S updates
    final List<Booking> displayAppointments = bookings.where((b) {
      if (b.date == null) return false;
      String bookingDate = b.date!.split(' ')[0].trim();
      bool dateMatch = bookingDate == todayStr;
      bool statusMatch =
          b.status.toLowerCase() == 'confirmed' ||
          b.status.toLowerCase() == 'approved';

      // Hide booking if its scheduled time is over the current time
      bool timeNotOver = true;
      if (b.time != null && b.time!.isNotEmpty) {
        try {
          final parts = b.time!.split(':');
          if (parts.length >= 2) {
            final now = DateTime.now();
            final bookingTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(parts[0].trim()),
              int.parse(parts[1].trim()),
            );
            timeNotOver = !now.isAfter(bookingTime);
          }
        } catch (e) {
          debugPrint("Error checking if today's booking time is over: $e");
        }
      }

      return statusMatch && dateMatch && timeNotOver;
    }).toList();

    return Container(
      height: 420,
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.defaultPadding,
        vertical: AppLayout.defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(
          color: AppColors.softBlack.withValues(alpha: 0.1),
          width: 0.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softBlack.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Today's Appointments",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.softBlack,
            ),
          ),
          const SizedBox(height: AppLayout.defaultPadding),
          Expanded(
            child: displayAppointments.isEmpty
                ? const Center(
                    child: Text(
                      "No confirmed appointments today",
                      style: TextStyle(color: AppColors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ...displayAppointments.map(
                          (booking) => StorageInfoCard(
                            id: booking.id.toString(),
                            title: booking.username ?? "Unknown Client",
                            subtitle: booking.serviceName ?? "Service",
                            time: _formatTime(booking.time),
                            price: booking.price ?? "0",
                            imagePath: booking.userProfileImage,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return "Time TBD";
    try {
      // Handle "HH:mm:ss" or "HH:mm"
      final parts = time.split(':');
      if (parts.length >= 2) {
        final now = DateTime.now();
        final dt = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        return DateFormat('h:mm a').format(dt);
      }
      return time;
    } catch (e) {
      return time;
    }
  }
}
