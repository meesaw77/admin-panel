import 'package:flutter/material.dart';
import 'package:admin/data/mock_data.dart';
import 'package:admin/models/review_model.dart';

class ReviewsController extends ChangeNotifier {
  // Data State
  List<Review> _reviews = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  
  // Pagination State
  int currentPage = 1;
  int limit = 20;
  bool hasMoreData = true;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // Filters & Selection
  String _searchQuery = "";
  final List<int> _selectedIds = [];

  // Getters
  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get isPollingActive => false;
  String get searchQuery => _searchQuery;
  List<int> get selectedIds => _selectedIds;

  // Filter Logic
  List<Review> get filteredReviews {
    List<Review> list = List.from(_reviews);
    // Sort: Promoted (Top) reviews first, then by date (newest first by ID)
    list.sort((a, b) {
      if (a.isPromoted && !b.isPromoted) return -1;
      if (!a.isPromoted && b.isPromoted) return 1;
      return b.id.compareTo(a.id);
    });
    return list;
  }

  void startPolling() {}
  void stopPolling() {}

  // --- UI Actions ---
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    // Filter locally
    if (query.isEmpty) {
      _reviews = List.from(MockData.reviews);
    } else {
      final q = query.toLowerCase();
      _reviews = MockData.reviews.where((r) =>
        r.userName.toLowerCase().contains(q) ||
        r.comment.toLowerCase().contains(q)
      ).toList();
    }
    notifyListeners();
  }

  void toggleSelection(int id) {
    _selectedIds.contains(id) ? _selectedIds.remove(id) : _selectedIds.add(id);
    notifyListeners();
  }

  void selectAll(bool selected) {
    _selectedIds.clear();
    if (selected) _selectedIds.addAll(filteredReviews.map((r) => r.id));
    notifyListeners();
  }

  // --- Local Data Operations ---

  Future<bool> fetchReviews({bool isSilent = false, bool loadMore = false}) async {
    if (!isSilent) { _isLoading = true; notifyListeners(); }
    else { _isSyncing = true; notifyListeners(); }

    await Future.delayed(const Duration(milliseconds: 200));

    if (_reviews.isEmpty) _reviews = List.from(MockData.reviews);
    hasMoreData = false; // All data loaded at once

    _isLoading = false;
    _isLoadingMore = false;
    _isSyncing = false;
    notifyListeners();
    return true;
  }

  Future<void> toggleVerify(int id, bool currentStatus) async {
    final index = _reviews.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reviews[index] = _reviews[index].copyWith(isVerified: !currentStatus);
      notifyListeners();
    }
  }

  Future<void> togglePromote(int id, bool currentStatus) async {
    final index = _reviews.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reviews[index] = _reviews[index].copyWith(isPromoted: !currentStatus);
      notifyListeners();
    }
  }

  Future<void> deleteReview(int id) async {
    _reviews.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  Future<void> bulkDelete(List<int> ids) async {
    if (ids.isEmpty) return;
    _reviews.removeWhere((r) => ids.contains(r.id));
    _selectedIds.clear();
    notifyListeners();
  }

  /// No-op — Google sync removed.
  Future<void> syncGoogleReviews() async {}
}
