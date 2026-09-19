import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:admin/controllers/auth_controller.dart';
import 'package:admin/data/mock_data.dart';
import 'package:admin/models/management_model.dart';
import 'package:admin/models/team_model.dart';

class ManagementController extends ChangeNotifier {
  // --- Data Lists ---
  List<UserModel> _users = [];

  // --- Getters ---
  List<UserModel> get users => _users;

  // --- State ---
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isAddingUser = false;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isAddingUser => _isAddingUser;
  bool get isPollingActive => false;

  // --- Edit State ---
  UserModel? _editingUser;
  UserModel? get editingUser => _editingUser;
  bool get isEditingAdmin => _editingUser?.role.toLowerCase() == "admin";

  // --- Selection State ---
  final Set<int> _selectedUserIds = {};
  Set<int> get selectedUserIds => _selectedUserIds;

  // --- User Form Controllers ---
  final userNameController = TextEditingController();
  final userEmailController = TextEditingController();
  final userPasswordController = TextEditingController();
  final userPhoneController = TextEditingController();

  // Work Categories
  static const List<String> availableWorkCategories = [
    'Category', 'Reviews', 'Blogs', 'Management', 'Membership',
    'Teams', 'Products', 'Services', 'Specialist', 'Promotions',
  ];

  static const Map<String, String> categoryDisplayNames = {
    'Category': 'Collections', 'Reviews': 'Feedback', 'Blogs': 'Articles',
    'Management': 'Staff', 'Membership': 'Membership', 'Teams': 'Our Team',
    'Products': 'Store', 'Services': 'Services', 'Specialist': 'Experts',
    'Promotions': 'Offers',
  };

  String getCategoryDisplayName(String category) {
    return categoryDisplayNames[category] ?? category;
  }

  List<String> selectedWorkCategories = [];
  String selectedRole = "staff";
  bool isUserBanned = false;

  // Image Picking
  File? pickedImage;
  Uint8List? webImage;
  int? _selectedTeamMemberId;
  int? get selectedTeamMemberId => _selectedTeamMemberId;

  ManagementController() { init(); }

  Future<void> init() async { await fetchUsers(); }

  void setAddingUser(bool val) {
    _isAddingUser = val;
    if (!val) clearUserForm();
    notifyListeners();
  }

  void clearUserForm() {
    userNameController.clear(); userEmailController.clear();
    userPasswordController.clear(); userPhoneController.clear();
    selectedWorkCategories.clear(); selectedRole = "staff";
    isUserBanned = false; _editingUser = null;
    pickedImage = null; webImage = null; _selectedTeamMemberId = null;
    notifyListeners();
  }

  void selectTeamMember(int? teamMemberId, List<dynamic> members) {
    _selectedTeamMemberId = teamMemberId;
    if (teamMemberId != null) {
      try {
        final member = members.firstWhere((m) => m is TeamMember && m.id == teamMemberId) as TeamMember;
        userNameController.text = member.name;
      } catch (e) {
        userNameController.text = '';
      }
    } else {
      userNameController.text = '';
    }
    notifyListeners();
  }

  void editUser(UserModel user) {
    _editingUser = user;
    userNameController.text = user.name;
    userEmailController.text = user.email;
    userPasswordController.clear();
    userPhoneController.text = user.phoneNumber ?? '';
    if (user.assignedWork != null && user.assignedWork!.isNotEmpty) {
      selectedWorkCategories = user.assignedWork!.split(',').map((e) => e.trim()).toList();
    } else {
      selectedWorkCategories = [];
    }
    selectedRole = user.role.toLowerCase();
    isUserBanned = user.isBanned;
    _isAddingUser = true;
    notifyListeners();
  }

  void toggleWorkCategory(String category) {
    selectedWorkCategories.contains(category) ? selectedWorkCategories.remove(category) : selectedWorkCategories.add(category);
    notifyListeners();
  }

  void toggleUserSelection(int id) {
    final user = _users.firstWhere((u) => u.id == id);
    if (user.role.toLowerCase() == "admin") return;
    _selectedUserIds.contains(id) ? _selectedUserIds.remove(id) : _selectedUserIds.add(id);
    notifyListeners();
  }

  void selectAllUsers(bool select) {
    _selectedUserIds.clear();
    if (select) _selectedUserIds.addAll(_users.where((u) => u.role.toLowerCase() != "admin").map((u) => u.id));
    notifyListeners();
  }

  Future<void> pickUserImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (kIsWeb) { webImage = await image.readAsBytes(); pickedImage = null; }
        else { pickedImage = File(image.path); webImage = null; }
        notifyListeners();
      }
    } catch (e) { debugPrint("Image Picker Error: $e"); }
  }

  void clearUserImage() {
    pickedImage = null; webImage = null;
    if (_editingUser != null) _editingUser = _editingUser!.copyWith(image: "");
    notifyListeners();
  }

  void startPolling() {}
  void stopPolling() {}

  Future<void> fetchUsers({bool skipLoading = false}) async {
    if (!skipLoading) { _isLoading = true; notifyListeners(); }
    await Future.delayed(const Duration(milliseconds: 200));
    if (_users.isEmpty) _users = List.from(MockData.users);
    _isLoading = false; notifyListeners();
  }

  Future<String?> saveUser({AuthController? auth}) async {
    final bool isAdminEdit = _editingUser?.role.toLowerCase() == "admin";
    if (userNameController.text.trim().isEmpty) return "Full Name is required";
    if (userEmailController.text.trim().isEmpty) return "Email is required";
    if (_editingUser == null && (userPasswordController.text.isEmpty || userPasswordController.text.length < 8)) {
      return "Password must be at least 8 characters";
    }
    if (_editingUser != null && userPasswordController.text.isNotEmpty && userPasswordController.text.length < 8) {
      return "Password must be at least 8 characters";
    }

    _isSaving = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    if (_editingUser != null) {
      final index = _users.indexWhere((u) => u.id == _editingUser!.id);
      if (index != -1) {
        _users[index] = _editingUser!.copyWith(
          name: userNameController.text.trim(),
          email: userEmailController.text.trim(),
          role: selectedRole,
          phoneNumber: userPhoneController.text.trim(),
          assignedWork: (selectedRole.toLowerCase() == "admin")
              ? availableWorkCategories.join(', ')
              : selectedWorkCategories.join(', '),
          isBanned: isAdminEdit ? _editingUser!.isBanned : isUserBanned,
        );
      }
    } else {
      final newId = _users.isEmpty ? 1 : _users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
      _users.add(UserModel(
        id: newId, name: userNameController.text.trim(),
        email: userEmailController.text.trim(), role: selectedRole,
        phoneNumber: userPhoneController.text.trim(),
        assignedWork: selectedWorkCategories.join(', '),
        isBanned: isUserBanned,
      ));
    }

    _isSaving = false;
    setAddingUser(false);
    return null;
  }

  Future<bool> deleteUser(int id) async {
    _users.removeWhere((u) => u.id == id);
    _selectedUserIds.remove(id);
    notifyListeners();
    return true;
  }

  Future<bool> deleteSelectedUsers() async {
    if (_selectedUserIds.isEmpty) return false;
    _users.removeWhere((u) => _selectedUserIds.contains(u.id));
    _selectedUserIds.clear();
    notifyListeners();
    return true;
  }

  void setUserRole(String r) { selectedRole = r; notifyListeners(); }
  void setUserBanned(bool b) { isUserBanned = b; notifyListeners(); }

  @override
  void dispose() {
    userNameController.dispose(); userEmailController.dispose();
    userPasswordController.dispose(); userPhoneController.dispose();
    super.dispose();
  }
}
