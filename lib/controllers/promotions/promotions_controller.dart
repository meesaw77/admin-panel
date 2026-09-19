import 'package:flutter/material.dart';
import 'package:admin/data/mock_data.dart';
import 'package:admin/models/promotion_model.dart';
import 'package:admin/utils/snack_bar_utils.dart';
import 'package:admin/mixins/image_picker_mixin.dart';

class PromotionsController extends ChangeNotifier with ImagePickerMixin {
  // Data State
  List<PromotionModel> _promotions = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isAdding = false;

  // Search and Selection
  String _searchQuery = "";
  final List<int> _selectedIds = [];

  // Form State
  PromotionModel? _editingPromotion;
  String _status = "Published";
  String _type = "Promotion";
  String _selectedTab = "All";

  final TextEditingController titleController = TextEditingController();

  // Getters
  List<PromotionModel> get promotions => _promotions;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isAdding => _isAdding;
  PromotionModel? get editingPromotion => _editingPromotion;
  String get status => _status;
  String get type => _type;
  String get selectedTab => _selectedTab;
  String get searchQuery => _searchQuery;
  List<int> get selectedIds => _selectedIds;
  bool get isPollingActive => false;

  List<PromotionModel> get filteredPromotions {
    List<PromotionModel> list = _promotions;
    if (_selectedTab != "All") list = list.where((p) => p.type == _selectedTab).toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => p.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  PromotionsController() { fetchPromotions(); }

  void setAdding(bool value) { _isAdding = value; if (!value) clearForm(); notifyListeners(); }
  void setStatus(String value) { _status = value; notifyListeners(); }
  void setType(String value) { _type = value; notifyListeners(); }
  void setSearchQuery(String query) { _searchQuery = query; notifyListeners(); }
  void setSelectedTab(String tab) { _selectedTab = tab; notifyListeners(); }

  void toggleSelection(int id) {
    _selectedIds.contains(id) ? _selectedIds.remove(id) : _selectedIds.add(id);
    notifyListeners();
  }

  void selectAll(bool select) {
    _selectedIds.clear();
    if (select) _selectedIds.addAll(filteredPromotions.map((p) => p.id));
    notifyListeners();
  }

  void editPromotion(PromotionModel promotion) {
    _editingPromotion = promotion;
    titleController.text = promotion.title;
    _status = promotion.status;
    _type = promotion.type;
    _isAdding = true;
    setImageState(file: null, web: null);
    notifyListeners();
  }

  void clearForm() {
    titleController.clear();
    _status = "Published";
    _type = "Promotion";
    _editingPromotion = null;
    clearImage();
    notifyListeners();
  }

  @override
  void clearImage() {
    super.clearImage();
    if (_editingPromotion != null) {
      _editingPromotion = _editingPromotion!.copyWith(clearImage: true);
    }
    notifyListeners();
  }

  void startPolling() {}
  void stopPolling() {}

  Future<void> fetchPromotions({bool skipLoading = false}) async {
    if (!skipLoading) { _isLoading = true; notifyListeners(); }
    await Future.delayed(const Duration(milliseconds: 200));
    if (_promotions.isEmpty) _promotions = List.from(MockData.promotions);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> savePromotion(BuildContext context) async {
    if (titleController.text.isEmpty) {
      SnackBarUtils.showSnackBar(context, "Title is required", isError: true);
      return false;
    }
    _isSaving = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    final bool isUpdating = _editingPromotion != null;
    if (isUpdating) {
      final index = _promotions.indexWhere((p) => p.id == _editingPromotion!.id);
      if (index != -1) {
        _promotions[index] = _editingPromotion!.copyWith(title: titleController.text.trim(), status: _status, type: _type);
      }
    } else {
      final newId = _promotions.isEmpty ? 1 : _promotions.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
      _promotions.add(PromotionModel(id: newId, title: titleController.text.trim(), status: _status, type: _type));
    }

    if (context.mounted) {
      SnackBarUtils.showSnackBar(context, isUpdating ? "Promotion updated successfully!" : "Promotion created successfully!");
    }
    _isSaving = false;
    setAdding(false);
    return true;
  }

  Future<void> deletePromotion(int id) async {
    _promotions.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> deleteSelectedPromotions() async {
    if (_selectedIds.isEmpty) return;
    _promotions.removeWhere((p) => _selectedIds.contains(p.id));
    _selectedIds.clear();
    notifyListeners();
  }

  @override
  void dispose() { titleController.dispose(); super.dispose(); }
}
