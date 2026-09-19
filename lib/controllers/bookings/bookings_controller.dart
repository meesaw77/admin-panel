import 'package:admin/controllers/auth_controller.dart';
import 'package:admin/data/mock_data.dart';
import 'package:admin/models/booking_model.dart';
import 'package:flutter/material.dart';

class BookingsController extends ChangeNotifier {
  AuthController? authController;

  BookingsController({this.authController});

  void update(AuthController auth) {
    if (authController != auth) {
      authController = auth;
      fetchBookings(silent: true);
    }
  }

  // State
  List<Booking> _bookings = [];
  bool _isLoading = false;
  bool _isSyncing = false;

  // Filters & Selection
  String _searchQuery = "";
  String _selectedTab =
      "Bookings"; // Options: "Bookings", "Completed", "Rejected/Canceled"
  final List<int> _selectedIds = [];

  // Getters
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get isPollingActive => false;
  String get searchQuery => _searchQuery;
  String get selectedTab => _selectedTab;
  List<int> get selectedIds => _selectedIds;

  // Logic for Notification Badge (Unseen Pending Bookings)
  bool get hasUnseenBookings => false;

  int get pendingBookingsCount {
    final user = authController?.currentUser;
    return _bookings.where((b) {
      final isPending = b.status.toLowerCase() == 'pending';
      if (user != null && user.role.toLowerCase() != 'admin') {
        final isForMe = b.staffName?.toLowerCase() == user.name.toLowerCase();
        return isPending && isForMe;
      }
      return isPending;
    }).length;
  }

  List<Booking> get roleFilteredPendingBookings {
    final user = authController?.currentUser;
    return _bookings.where((b) {
      final isPending = b.status.toLowerCase() == 'pending';
      if (user != null && user.role.toLowerCase() != 'admin') {
        final isForMe = b.staffName?.toLowerCase() == user.name.toLowerCase();
        return isPending && isForMe;
      }
      return isPending;
    }).toList();
  }

  void markBookingsAsSeen() {
    notifyListeners();
  }

  // Filter Logic
  List<Booking> get filteredBookings {
    List<Booking> list = _bookings;

    // 1. Search Filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((booking) {
        final name = booking.username?.toLowerCase() ?? '';
        final service = booking.serviceName?.toLowerCase() ?? '';
        final id = booking.id.toString();
        return name.contains(query) ||
            service.contains(query) ||
            id.contains(query);
      }).toList();
    }

    // 2. Staff Filter
    final user = authController?.currentUser;
    if (user != null && user.role.toLowerCase() != 'admin') {
      list = list.where((booking) {
        return booking.staffName?.toLowerCase() == user.name.toLowerCase();
      }).toList();
    }

    // 3. Tab Filter
    return list.where((booking) {
      final s = booking.status.toLowerCase();
      if (_selectedTab == "Bookings") {
        return ["pending", "waiting", "confirmed", "approved"].contains(s);
      } else if (_selectedTab == "Completed") {
        return s == "completed";
      } else if (_selectedTab == "Rejected/Canceled") {
        return [
          "rejected",
          "cancelled",
          "canceled",
          "failed",
          "suspended",
        ].contains(s);
      }
      return true; // Default fallback
    }).toList();
  }

  // UI Actions
  void setSelectedTab(String tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      _selectedIds.clear(); // Clear selection when switching tabs
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAll(bool selected) {
    _selectedIds.clear();
    if (selected) {
      _selectedIds.addAll(filteredBookings.map((b) => b.id));
    }
    notifyListeners();
  }

  // Data Operations (local only)

  Future<bool> fetchBookings({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    } else {
      _isSyncing = true;
      notifyListeners();
    }

    // Simulate brief loading
    await Future.delayed(const Duration(milliseconds: 300));

    if (_bookings.isEmpty) {
      _bookings = List.from(MockData.bookings);
    }

    _isLoading = false;
    _isSyncing = false;
    notifyListeners();
    return true;
  }

  Future<String> updateBookingStatus(int id, String status) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final old = _bookings[index];
      _bookings[index] = Booking(
        id: old.id,
        username: old.username,
        serviceName: old.serviceName,
        status: status,
        date: old.date,
        time: old.time,
        duration: old.duration,
        loyaltyPoints: old.loyaltyPoints,
        staffName: old.staffName,
        price: old.price,
        userProfileImage: old.userProfileImage,
        paymentMethod: old.paymentMethod,
        paymentProof: old.paymentProof,
        appointmentType: old.appointmentType,
        userPhone: old.userPhone,
        userEmail: old.userEmail,
      );
      notifyListeners();
    }
    return "Status updated to $status";
  }

  Future<String?> deleteBooking(int id) async {
    _bookings.removeWhere((b) => b.id == id);
    if (_selectedIds.contains(id)) _selectedIds.remove(id);
    notifyListeners();
    return null;
  }

  Future<String?> bulkDelete(List<int> ids) async {
    if (ids.isEmpty) return null;
    _bookings.removeWhere((b) => ids.contains(b.id));
    _selectedIds.clear();
    notifyListeners();
    return null;
  }

  // Polling stubs
  void startPolling() {}
  void stopPolling() {}
}
