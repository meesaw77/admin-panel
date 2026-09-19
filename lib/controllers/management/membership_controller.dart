import 'package:flutter/material.dart';
import 'package:admin/data/mock_data.dart';
import '../../models/membership_model.dart';
import '../../models/membership_purchase_model.dart';
import '../../models/service_model.dart';

class MembershipController extends ChangeNotifier {
  bool _isAdding = false;
  bool _isLoading = false;
  bool get isAdding => _isAdding;
  bool get isLoading => _isLoading;

  List<MembershipModel> _memberships = [];
  List<MembershipModel> get memberships => _memberships;

  List<MembershipPurchaseModel> _purchases = [];
  List<MembershipPurchaseModel> get purchases => _purchases;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  String _purchaseSearchQuery = "";
  String get purchaseSearchQuery => _purchaseSearchQuery;

  MembershipModel? _editingMembership;
  MembershipModel? get editingMembership => _editingMembership;

  String? _purchaseError;
  String? get purchaseError => _purchaseError;

  MembershipController() {
    fetchMemberships();
    fetchPurchases();
  }

  bool _isRecurring = true;
  String _selectedSessionsType = "Limited";
  String _selectedFrequency = "Monthly (Until canceled)";

  bool get isRecurring => _isRecurring;
  String get selectedSessionsType => _selectedSessionsType;
  String get selectedFrequency => _selectedFrequency;

  bool _showServicesList = false;
  bool get showServicesList => _showServicesList;

  final List<int> _selectedServiceIds = [];
  List<int> get selectedServiceIds => _selectedServiceIds;

  String? _selectedServicesCategory;
  String? get selectedServicesCategory => _selectedServicesCategory;

  String _servicesSearchQuery = "";
  String get servicesSearchQuery => _servicesSearchQuery;

  void setSelectedServicesCategory(String? category) {
    _selectedServicesCategory = category;
    notifyListeners();
  }

  void setServicesSearchQuery(String query) {
    _servicesSearchQuery = query;
    notifyListeners();
  }

  final List<int> _selectedMembershipIds = [];
  List<int> get selectedMembershipIds => _selectedMembershipIds;

  List<MembershipModel> get filteredMemberships {
    final query = _searchQuery;
    if (query.isEmpty) return _memberships;
    return _memberships
        .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setPurchaseSearchQuery(String query) {
    _purchaseSearchQuery = query;
    if (purchaseSearchController.text != query) {
      purchaseSearchController.text = query;
    }
    notifyListeners();
  }

  List<MembershipPurchaseModel> get filteredPurchases {
    final query = _purchaseSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return _purchases;
    return _purchases.where((p) {
      final mName = p.membershipName.toLowerCase();
      final uName = (p.userName ?? '').toLowerCase();
      final uPhone = (p.userPhone ?? '').toLowerCase();
      final method = p.paymentMethod.toLowerCase();
      final status = p.status.toLowerCase();
      return mName.contains(query) ||
          uName.contains(query) ||
          uPhone.contains(query) ||
          method.contains(query) ||
          status.contains(query);
    }).toList();
  }

  Future<void> fetchMemberships({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (_memberships.isEmpty) _memberships = List.from(MockData.memberships);
    if (!silent) _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPurchases({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _purchaseError = null;
      notifyListeners();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (_purchases.isEmpty) {
      _purchases = MockData.purchasesJson
          .map((json) => MembershipPurchaseModel.fromJson(json))
          .toList();
    }
    if (!silent) _isLoading = false;
    notifyListeners();
  }

  Future<String> updatePurchaseStatus(int id, String status) async {
    final index = _purchases.indexWhere((p) => p.id == id);
    if (index != -1) {
      // Rebuild with new status via fromJson with modified data
      final oldJson = {
        'id': _purchases[index].id.toString(),
        'user_id': _purchases[index].userId.toString(),
        'membership_name': _purchases[index].membershipName,
        'price': _purchases[index].price.toString(),
        'payment_method': _purchases[index].paymentMethod,
        'status': status,
        'created_at': _purchases[index].createdAt,
        'user_name': _purchases[index].userName,
        'user_image': _purchases[index].userImage,
      };
      _purchases[index] = MembershipPurchaseModel.fromJson(oldJson);
      notifyListeners();
    }
    return "Status updated successfully";
  }

  Future<void> changePurchasePlan(int id, int targetTier) async {
    // No-op for mock data
  }

  Future<void> deletePurchase(int id) async {
    _purchases.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void toggleServicesList() {
    _showServicesList = !_showServicesList;
    notifyListeners();
  }

  void toggleServiceSelection(int id) {
    _selectedServiceIds.contains(id)
        ? _selectedServiceIds.remove(id)
        : _selectedServiceIds.add(id);
    notifyListeners();
  }

  void toggleMembershipSelection(int id) {
    _selectedMembershipIds.contains(id)
        ? _selectedMembershipIds.remove(id)
        : _selectedMembershipIds.add(id);
    notifyListeners();
  }

  void toggleAllMemberships() {
    if (_selectedMembershipIds.length == filteredMemberships.length) {
      _selectedMembershipIds.clear();
    } else {
      _selectedMembershipIds.clear();
      _selectedMembershipIds.addAll(filteredMemberships.map((m) => m.id));
    }
    notifyListeners();
  }

  void setSessionsType(String value) {
    _selectedSessionsType = value;
    notifyListeners();
  }

  void setIsRecurring(bool value) {
    _isRecurring = value;
    notifyListeners();
  }

  void setFrequency(String value) {
    _selectedFrequency = value;
    notifyListeners();
  }

  void setAdding(
    bool value, {
    MembershipModel? membership,
    List<Service>? allServices,
  }) async {
    if (value && membership != null) {
      _editingMembership = membership;
      nameController.text = membership.name;
      descriptionController.text = membership.description ?? "";
      priceController.text = membership.price.toString();
      sessionsController.text = membership.sessions;
      termsController.text = membership.terms ?? "";
      _selectedSessionsType =
          membership.sessions.toLowerCase().contains("unlimited")
          ? "Unlimited"
          : "Limited";
      String freq = membership.frequency;
      if (freq == "Monthly") freq = "Monthly (Until canceled)";
      if (freq == "Yearly") freq = "Yearly (Until canceled)";
      _selectedFrequency = freq;
      _isRecurring = membership.isRecurring;

      _selectedServiceIds.clear();
      if (allServices != null &&
          allServices.isNotEmpty &&
          membership.services.isNotEmpty) {
        for (var name in membership.services) {
          final trimmedName = name.trim().toLowerCase();
          if (trimmedName.isEmpty) continue;
          try {
            final service = allServices.firstWhere(
              (s) => s.name.trim().toLowerCase() == trimmedName,
              orElse: () => Service(
                id: -1,
                name: "",
                description: "",
                category: "",
                price: 0,
                loyaltyPoints: 0,
                duration: 0,
                status: "",
              ),
            );
            if (service.id != -1) _selectedServiceIds.add(service.id);
          } catch (e) {
            debugPrint("Error finding service: $e");
          }
        }
      }
      _isAdding = true;
      notifyListeners();
    } else {
      _isAdding = value;
      if (!value) {
        clearForm();
      } else {
        _selectedServicesCategory = null;
        _servicesSearchQuery = "";
      }
      notifyListeners();
    }
  }

  // Form Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final sessionsController = TextEditingController();
  final priceController = TextEditingController();
  final termsController = TextEditingController();
  final servicesSearchController = TextEditingController();
  final purchaseSearchController = TextEditingController();

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    sessionsController.clear();
    priceController.clear();
    termsController.clear();
    servicesSearchController.clear();
    _selectedServiceIds.clear();
    _isRecurring = true;
    _editingMembership = null;
    _selectedServicesCategory = null;
    _servicesSearchQuery = "";
    notifyListeners();
  }

  Future<bool> saveMembership() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    if (_editingMembership != null) {
      final index = _memberships.indexWhere(
        (m) => m.id == _editingMembership!.id,
      );
      if (index != -1) {
        _memberships[index] = MembershipModel(
          id: _editingMembership!.id,
          name: nameController.text,
          servicesCount: _selectedServiceIds.length,
          isRecurring: _isRecurring,
          sessions: sessionsController.text,
          price: double.tryParse(priceController.text) ?? 0.0,
          frequency: _selectedFrequency,
          description: descriptionController.text,
          terms: termsController.text,
          services: _editingMembership!.services,
        );
      }
    } else {
      final newId = _memberships.isEmpty
          ? 1
          : _memberships.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;
      _memberships.add(
        MembershipModel(
          id: newId,
          name: nameController.text,
          servicesCount: _selectedServiceIds.length,
          isRecurring: _isRecurring,
          sessions: sessionsController.text,
          price: double.tryParse(priceController.text) ?? 0.0,
          frequency: _selectedFrequency,
          description: descriptionController.text,
          terms: termsController.text,
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> deleteSelectedMemberships() async {
    _memberships.removeWhere((m) => _selectedMembershipIds.contains(m.id));
    _selectedMembershipIds.clear();
    notifyListeners();
  }

  Future<void> deleteMembership(int id) async {
    _memberships.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void startPolling() {}
  void stopPolling() {}

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    sessionsController.dispose();
    priceController.dispose();
    termsController.dispose();
    servicesSearchController.dispose();
    purchaseSearchController.dispose();
    super.dispose();
  }
}
