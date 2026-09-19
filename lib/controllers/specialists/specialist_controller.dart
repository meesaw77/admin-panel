import 'package:flutter/material.dart';
import 'package:admin/data/mock_data.dart';
import 'package:admin/models/specialist_model.dart';
import 'package:admin/mixins/image_picker_mixin.dart';
import 'package:admin/mixins/word_count_mixin.dart';
import 'package:admin/utils/snack_bar_utils.dart';

class SpecialistController extends ChangeNotifier
    with ImagePickerMixin, WordCountMixin {
  // Data State
  List<Specialist> _specialists = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isAdding = false;

  // Search and Selection
  String _searchQuery = "";
  final List<int> _selectedIds = [];

  // Service Selection State
  final List<String> _selectedServices = [];
  String? _selectedServicesCategory;
  String _servicesSearchQuery = "";
  bool _showServicesList = false;

  // Form State
  Specialist? _editingSpecialist;
  String _status = "Published";

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController specializationsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController servicesSearchController = TextEditingController();

  // Getters
  List<Specialist> get specialists => _specialists;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isAdding => _isAdding;
  Specialist? get editingSpecialist => _editingSpecialist;
  String get status => _status;
  String get searchQuery => _searchQuery;
  List<int> get selectedIds => _selectedIds;
  bool get isPollingActive => false;

  List<String> get selectedServices => _selectedServices;
  String? get selectedServicesCategory => _selectedServicesCategory;
  String get servicesSearchQuery => _servicesSearchQuery;
  bool get showServicesList => _showServicesList;

  List<Specialist> get filteredSpecialists {
    final query = _searchQuery.toLowerCase();
    final list = _searchQuery.isEmpty
        ? List<Specialist>.from(_specialists)
        : _specialists.where((s) => s.name.toLowerCase().contains(query) || s.specializations.toLowerCase().contains(query)).toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  SpecialistController() {
    fetchSpecialists();
    descriptionController.addListener(() { updateWordCount(descriptionController.text); });
  }

  void setAdding(bool value) { _isAdding = value; if (!value) clearForm(); notifyListeners(); }
  void setStatus(String value) { _status = value; notifyListeners(); }
  void setSearchQuery(String query) { _searchQuery = query; notifyListeners(); }
  void setSelectedServicesCategory(String? category) { _selectedServicesCategory = category; notifyListeners(); }
  void setServicesSearchQuery(String query) { _servicesSearchQuery = query; notifyListeners(); }
  void setShowServicesList(bool value) { _showServicesList = value; notifyListeners(); }

  void toggleServiceSelection(String serviceName) {
    _selectedServices.contains(serviceName) ? _selectedServices.remove(serviceName) : _selectedServices.add(serviceName);
    notifyListeners();
  }

  void toggleSelection(int id) {
    _selectedIds.contains(id) ? _selectedIds.remove(id) : _selectedIds.add(id);
    notifyListeners();
  }

  void selectAll(bool select) {
    _selectedIds.clear();
    if (select) _selectedIds.addAll(filteredSpecialists.map((s) => s.id));
    notifyListeners();
  }

  void editSpecialist(Specialist specialist) {
    _editingSpecialist = specialist;
    nameController.text = specialist.name;
    roleController.text = specialist.role;
    experienceController.text = specialist.experience;
    specializationsController.text = specialist.specializations;
    _selectedServices.clear();
    if (specialist.specializations.isNotEmpty) {
      _selectedServices.addAll(specialist.specializations.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
    }
    descriptionController.text = specialist.description ?? "";
    _status = specialist.status;
    _isAdding = true;
    _showServicesList = false;
    setImageState(file: null, web: null);
    updateWordCount(specialist.description ?? "");
    notifyListeners();
  }

  void clearForm() {
    nameController.clear(); roleController.clear(); experienceController.clear();
    specializationsController.clear(); descriptionController.clear(); servicesSearchController.clear();
    _selectedServices.clear(); _selectedServicesCategory = null; _servicesSearchQuery = "";
    _showServicesList = false; _status = "Published"; _editingSpecialist = null;
    clearImage(); resetWordCount(); notifyListeners();
  }

  @override
  void clearImage() {
    super.clearImage();
    if (_editingSpecialist != null) _editingSpecialist = _editingSpecialist!.copyWith(clearImage: true);
    notifyListeners();
  }

  void startPolling() {}
  void stopPolling() {}

  Future<void> fetchSpecialists({bool skipLoading = false}) async {
    if (!skipLoading) { _isLoading = true; notifyListeners(); }
    await Future.delayed(const Duration(milliseconds: 200));
    if (_specialists.isEmpty) _specialists = List.from(MockData.specialists);
    _isLoading = false; notifyListeners();
  }

  Future<bool> saveSpecialist(BuildContext context) async {
    if (nameController.text.isEmpty) { SnackBarUtils.showSnackBar(context, "Name is required", isError: true); return false; }
    if (!isDescriptionValid) { SnackBarUtils.showSnackBar(context, "Description is too long (max 200 words)", isError: true); return false; }

    _isSaving = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    final isUpdating = _editingSpecialist != null;
    if (isUpdating) {
      final index = _specialists.indexWhere((s) => s.id == _editingSpecialist!.id);
      if (index != -1) {
        _specialists[index] = _editingSpecialist!.copyWith(
          name: nameController.text.trim(), role: roleController.text.trim(),
          experience: experienceController.text.trim(),
          specializations: _selectedServices.join(', '),
          description: descriptionController.text.trim(), status: _status,
        );
      }
    } else {
      final newId = _specialists.isEmpty ? 1 : _specialists.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
      _specialists.add(Specialist(id: newId, name: nameController.text.trim(), role: roleController.text.trim(),
        experience: experienceController.text.trim(), specializations: _selectedServices.join(', '),
        description: descriptionController.text.trim(), status: _status));
    }

    if (context.mounted) { SnackBarUtils.showSnackBar(context, isUpdating ? "Specialist details updated successfully!" : "Specialist added successfully!"); }
    _isSaving = false; setAdding(false); return true;
  }

  Future<void> deleteSpecialist(int id) async { _specialists.removeWhere((s) => s.id == id); notifyListeners(); }

  Future<void> deleteSelectedSpecialists() async {
    if (_selectedIds.isEmpty) return;
    _specialists.removeWhere((s) => _selectedIds.contains(s.id));
    _selectedIds.clear(); notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose(); roleController.dispose(); experienceController.dispose();
    specializationsController.dispose(); descriptionController.dispose(); servicesSearchController.dispose();
    super.dispose();
  }
}
