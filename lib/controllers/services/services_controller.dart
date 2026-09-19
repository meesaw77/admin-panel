import 'package:flutter/material.dart';
import 'package:admin/data/mock_data.dart';
import 'package:admin/models/service_model.dart';
import 'package:admin/utils/snack_bar_utils.dart';
import 'package:admin/mixins/image_picker_mixin.dart';
import 'package:admin/mixins/word_count_mixin.dart';

class ServicesController extends ChangeNotifier
    with ImagePickerMixin, WordCountMixin {
  // Data State
  List<Service> _services = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isAdding = false;

  // Search and Selection
  String _searchQuery = "";
  final List<int> _selectedIds = [];

  // Form State
  Service? _editingService;
  String _status = "Published";
  String? _selectedCategory;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController loyaltyPointsController = TextEditingController();
  final TextEditingController durationHourController = TextEditingController();
  final TextEditingController durationMinuteController = TextEditingController();

  // Getters
  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isAdding => _isAdding;
  Service? get editingService => _editingService;
  String get status => _status;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<int> get selectedIds => _selectedIds;
  bool get isPollingActive => false;

  List<Service> get filteredServices {
    if (_searchQuery.isEmpty) return _services;
    final query = _searchQuery.toLowerCase();
    return _services
        .where((s) =>
    s.name.toLowerCase().contains(query) ||
        s.category.toLowerCase().contains(query))
        .toList();
  }

  ServicesController() {
    fetchServices();
  }

  // ---------------- UI ACTIONS ----------------

  void setAdding(bool value) {
    _isAdding = value;
    if (!value) clearForm();
    notifyListeners();
  }

  void setStatus(String value) {
    _status = value;
    notifyListeners();
  }

  void setCategory(String? name) {
    _selectedCategory = name;
    notifyListeners();
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

  void selectAll(bool select) {
    _selectedIds.clear();
    if (select) {
      _selectedIds.addAll(filteredServices.map((s) => s.id));
    }
    notifyListeners();
  }

  void editService(Service service) {
    _editingService = service;
    nameController.text = service.name;
    descriptionController.text = service.description;
    priceController.text = service.price.toString();
    loyaltyPointsController.text = service.loyaltyPoints.toString();
    final hours = service.duration ~/ 60;
    final minutes = service.duration % 60;
    durationHourController.text = hours > 0 ? hours.toString() : "";
    durationMinuteController.text = minutes > 0 ? minutes.toString() : "";
    _selectedCategory = service.category.isEmpty ? null : service.category;
    _status = service.status;
    _isAdding = true;
    setImageState(file: null, web: null);
    updateWordCount(service.description);
    notifyListeners();
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    loyaltyPointsController.clear();
    durationHourController.clear();
    durationMinuteController.clear();
    _editingService = null;
    _selectedCategory = null;
    clearImage();
    resetWordCount();
    notifyListeners();
  }

  @override
  void clearImage() {
    super.clearImage();
    if (_editingService != null) {
      _editingService = _editingService!.copyWith(clearImage: true);
    }
    notifyListeners();
  }

  // Polling stubs
  void startPolling() {}
  void stopPolling() {}

  // ---------------- LOCAL DATA OPERATIONS ----------------

  Future<void> fetchServices({bool skipLoading = false}) async {
    if (!skipLoading) {
      _isLoading = true;
      notifyListeners();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (_services.isEmpty) {
      _services = List.from(MockData.services);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveService(BuildContext context) async {
    if (nameController.text.isEmpty) {
      SnackBarUtils.showSnackBar(context, "Service Name is required", isError: true);
      return false;
    }
    if (!isDescriptionValid) {
      SnackBarUtils.showSnackBar(context, "Description is too long (max 200 words)", isError: true);
      return false;
    }

    _isSaving = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    final bool isUpdating = _editingService != null;
    final duration = ((int.tryParse(durationHourController.text.trim()) ?? 0) * 60 +
        (int.tryParse(durationMinuteController.text.trim()) ?? 0));

    if (isUpdating) {
      final index = _services.indexWhere((s) => s.id == _editingService!.id);
      if (index != -1) {
        _services[index] = _editingService!.copyWith(
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          category: _selectedCategory ?? _editingService!.category,
          price: double.tryParse(priceController.text.trim()) ?? 0,
          loyaltyPoints: int.tryParse(loyaltyPointsController.text.trim()) ?? 0,
          duration: duration,
          status: _status,
        );
      }
    } else {
      final newId = _services.isEmpty ? 1 : _services.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
      _services.add(Service(
        id: newId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        category: _selectedCategory ?? "",
        price: double.tryParse(priceController.text.trim()) ?? 0,
        loyaltyPoints: int.tryParse(loyaltyPointsController.text.trim()) ?? 0,
        duration: duration,
        status: _status,
      ));
    }

    if (context.mounted) {
      SnackBarUtils.showSnackBar(context, isUpdating ? "Service updated successfully!" : "Service created successfully!");
    }

    _isSaving = false;
    setAdding(false);
    return true;
  }

  Future<void> deleteService(int id) async {
    _services.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Future<void> deleteSelectedServices() async {
    if (_selectedIds.isEmpty) return;
    _services.removeWhere((s) => _selectedIds.contains(s.id));
    _selectedIds.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    loyaltyPointsController.dispose();
    durationHourController.dispose();
    durationMinuteController.dispose();
    super.dispose();
  }
}
