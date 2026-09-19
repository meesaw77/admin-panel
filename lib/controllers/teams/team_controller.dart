import 'package:flutter/material.dart';
import 'package:admin/data/mock_data.dart';
import 'package:admin/models/team_model.dart';
import 'package:admin/mixins/image_picker_mixin.dart';
import 'package:admin/mixins/word_count_mixin.dart';
import 'package:admin/utils/snack_bar_utils.dart';

class TeamController extends ChangeNotifier
    with ImagePickerMixin, WordCountMixin {
  // Data State
  List<TeamMember> _teamMembers = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isAdding = false;

  // Search and Selection
  String _searchQuery = "";
  final List<int> _selectedIds = [];

  // Form State
  TeamMember? _editingMember;
  String _status = "Published";

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController specializationsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Specialization Dropdown State
  List<String> _selectedServices = [];
  String? _selectedCategory;
  bool _isDropdownOpen = false;

  // Social Links State
  final TextEditingController socialLinkInputController = TextEditingController();
  final Map<String, TextEditingController> socialControllers = {
    'Facebook': TextEditingController(),
    'Instagram': TextEditingController(),
  };
  String _selectedSocialPlatform = 'None';

  // Getters
  List<TeamMember> get teamMembers => _teamMembers;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isAdding => _isAdding;
  TeamMember? get editingMember => _editingMember;
  String get status => _status;
  String get searchQuery => _searchQuery;
  List<int> get selectedIds => _selectedIds;
  bool get isPollingActive => false;

  List<String> get selectedServices => _selectedServices;
  String? get selectedCategory => _selectedCategory;
  bool get isDropdownOpen => _isDropdownOpen;
  String get selectedSocialPlatform => _selectedSocialPlatform;

  List<TeamMember> get filteredMembers {
    if (_searchQuery.isEmpty) return _teamMembers;
    final query = _searchQuery.toLowerCase();
    return _teamMembers.where((m) =>
        m.name.toLowerCase().contains(query) ||
        m.specializations.toLowerCase().contains(query) ||
        m.role.toLowerCase().contains(query)).toList();
  }

  TeamController() {
    fetchTeamMembers();
    descriptionController.addListener(() => updateWordCount(descriptionController.text));
  }

  void setAdding(bool value) { _isAdding = value; if (!value) clearForm(); notifyListeners(); }
  void setStatus(String value) { _status = value; notifyListeners(); }
  void setSearchQuery(String query) { _searchQuery = query; notifyListeners(); }

  void toggleSelection(int id) {
    _selectedIds.contains(id) ? _selectedIds.remove(id) : _selectedIds.add(id);
    notifyListeners();
  }

  void setSelectedCategory(String? category) { _selectedCategory = category; notifyListeners(); }

  void toggleServiceSelection(String serviceName) {
    _selectedServices.contains(serviceName) ? _selectedServices.remove(serviceName) : _selectedServices.add(serviceName);
    specializationsController.text = _selectedServices.join(', ');
    notifyListeners();
  }

  void removeServiceSelection(String serviceName) {
    _selectedServices.remove(serviceName);
    specializationsController.text = _selectedServices.join(', ');
    notifyListeners();
  }

  void setDropdownOpen(bool isOpen) { _isDropdownOpen = isOpen; notifyListeners(); }

  void setSelectedSocialPlatform(String platform) {
    _selectedSocialPlatform = platform;
    socialLinkInputController.clear();
    notifyListeners();
  }

  void addSocialLink() {
    final link = socialLinkInputController.text.trim();
    if (link.isEmpty || _selectedSocialPlatform == 'None') return;
    if (socialControllers.containsKey(_selectedSocialPlatform)) {
      socialControllers[_selectedSocialPlatform]!.text = link;
      _selectedSocialPlatform = 'None';
      socialLinkInputController.clear();
      notifyListeners();
    }
  }

  void removeSocialLink(String platform) {
    if (socialControllers.containsKey(platform)) {
      socialControllers[platform]!.clear();
      notifyListeners();
    }
  }

  void initializeSelectedServices() {
    if (specializationsController.text.isNotEmpty) {
      _selectedServices = specializationsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else {
      _selectedServices = [];
    }
    notifyListeners();
  }

  void selectAll(bool select) {
    _selectedIds.clear();
    if (select) _selectedIds.addAll(filteredMembers.map((m) => m.id));
    notifyListeners();
  }

  void editMember(TeamMember member) {
    _editingMember = member;
    nameController.text = member.name;
    roleController.text = member.role;
    experienceController.text = member.experience;
    specializationsController.text = member.specializations;
    descriptionController.text = member.description ?? "";
    _status = member.status;
    socialControllers.forEach((key, controller) => controller.clear());
    _selectedSocialPlatform = 'None';
    socialLinkInputController.clear();
    member.socialLinks.forEach((key, value) {
      if (socialControllers.containsKey(key)) socialControllers[key]!.text = value;
    });
    _isAdding = true;
    setImageState(file: null, web: null);
    updateWordCount(descriptionController.text);
    initializeSelectedServices();
    notifyListeners();
  }

  void clearForm() {
    nameController.clear(); roleController.clear(); experienceController.clear();
    specializationsController.clear(); descriptionController.clear();
    socialControllers.forEach((key, controller) => controller.clear());
    _selectedSocialPlatform = 'None';
    clearImage(); _status = "Published"; _editingMember = null;
    _selectedServices.clear(); _selectedCategory = null; _isDropdownOpen = false;
    resetWordCount(); notifyListeners();
  }

  @override
  void clearImage() {
    super.clearImage();
    if (_editingMember != null) _editingMember = _editingMember!.copyWith(clearImage: true);
    notifyListeners();
  }

  void startPolling() {}
  void stopPolling() {}

  Future<void> fetchTeamMembers({bool skipLoading = false}) async {
    if (!skipLoading) { _isLoading = true; notifyListeners(); }
    await Future.delayed(const Duration(milliseconds: 200));
    if (_teamMembers.isEmpty) _teamMembers = List.from(MockData.teamMembers);
    _isLoading = false; notifyListeners();
  }

  Future<bool> saveMember(BuildContext context) async {
    if (nameController.text.isEmpty) {
      if (context.mounted) SnackBarUtils.showSnackBar(context, "Name cannot be empty", isError: true);
      return false;
    }
    if (!isDescriptionValid) {
      if (context.mounted) SnackBarUtils.showSnackBar(context, "Description is too long", isError: true);
      return false;
    }

    _isSaving = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    final isUpdating = _editingMember != null;
    final socialLinks = <String, String>{};
    socialControllers.forEach((key, controller) {
      if (controller.text.trim().isNotEmpty) socialLinks[key] = controller.text.trim();
    });

    if (isUpdating) {
      final index = _teamMembers.indexWhere((m) => m.id == _editingMember!.id);
      if (index != -1) {
        _teamMembers[index] = _editingMember!.copyWith(
          name: nameController.text.trim(), role: roleController.text.trim(),
          experience: experienceController.text.trim(),
          specializations: specializationsController.text.trim(),
          description: descriptionController.text.trim(), status: _status,
          socialLinks: socialLinks,
        );
      }
    } else {
      final newId = _teamMembers.isEmpty ? 1 : _teamMembers.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;
      _teamMembers.add(TeamMember(id: newId, name: nameController.text.trim(), role: roleController.text.trim(),
        experience: experienceController.text.trim(), specializations: specializationsController.text.trim(),
        description: descriptionController.text.trim(), status: _status, socialLinks: socialLinks));
    }

    if (context.mounted) {
      SnackBarUtils.showSnackBar(context, isUpdating ? "Member updated successfully!" : "Member added successfully!");
    }
    _isSaving = false; setAdding(false); return true;
  }

  Future<void> deleteMember(int id) async { _teamMembers.removeWhere((m) => m.id == id); notifyListeners(); }

  Future<void> deleteSelectedMembers() async {
    if (_selectedIds.isEmpty) return;
    _teamMembers.removeWhere((m) => _selectedIds.contains(m.id));
    _selectedIds.clear(); notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose(); roleController.dispose(); experienceController.dispose();
    specializationsController.dispose(); descriptionController.dispose();
    socialControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
}
