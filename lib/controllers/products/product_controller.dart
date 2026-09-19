import 'package:flutter/material.dart';
import 'package:admin/data/mock_data.dart';
import 'package:admin/models/product_model.dart';
import 'package:admin/mixins/image_picker_mixin.dart';
import 'package:admin/mixins/word_count_mixin.dart';
import 'package:admin/utils/snack_bar_utils.dart';

class ProductController extends ChangeNotifier
    with ImagePickerMixin, WordCountMixin {
  // Data State
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isAdding = false;

  // Search and Selection
  String _searchQuery = "";
  final List<int> _selectedIds = [];

  // Form State
  Product? _editingProduct;
  String _status = "Published";
  String _currentView = "All Products";

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isAdding => _isAdding;
  Product? get editingProduct => _editingProduct;
  String get status => _status;
  String get currentView => _currentView;
  String get searchQuery => _searchQuery;
  List<int> get selectedIds => _selectedIds;
  bool get isPollingActive => false;

  List<Product> get filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    final query = _searchQuery.toLowerCase();
    return _products
        .where((p) => p.name.toLowerCase().contains(query) || p.description.toLowerCase().contains(query))
        .toList();
  }

  ProductController() {
    fetchProducts();
  }

  void setAdding(bool value) {
    _isAdding = value;
    if (!value) clearForm();
    notifyListeners();
  }

  void setStatus(String value) { _status = value; notifyListeners(); }
  void setCurrentView(String view) { _currentView = view; notifyListeners(); }
  void setSearchQuery(String query) { _searchQuery = query; notifyListeners(); }

  void toggleSelection(int id) {
    _selectedIds.contains(id) ? _selectedIds.remove(id) : _selectedIds.add(id);
    notifyListeners();
  }

  void selectAll(bool select) {
    _selectedIds.clear();
    if (select) _selectedIds.addAll(filteredProducts.map((p) => p.id));
    notifyListeners();
  }

  void editProduct(Product product) {
    _editingProduct = product;
    nameController.text = product.name;
    descriptionController.text = product.description;
    priceController.text = product.price.toString();
    _status = product.status;
    _isAdding = true;
    setImageState(file: null, web: null);
    updateWordCount(product.description);
    notifyListeners();
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    _editingProduct = null;
    clearImage();
    resetWordCount();
    notifyListeners();
  }

  void startPolling() {}
  void stopPolling() {}

  Future<void> fetchProducts({bool skipLoading = false}) async {
    if (!skipLoading) { _isLoading = true; notifyListeners(); }
    await Future.delayed(const Duration(milliseconds: 200));
    if (_products.isEmpty) _products = List.from(MockData.products);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveProduct(BuildContext context) async {
    if (nameController.text.isEmpty) {
      SnackBarUtils.showSnackBar(context, "Name is required", isError: true);
      return false;
    }
    if (!isDescriptionValid) {
      SnackBarUtils.showSnackBar(context, "Description is too long (max 200 words)", isError: true);
      return false;
    }

    _isSaving = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    final bool isUpdating = _editingProduct != null;
    if (isUpdating) {
      final index = _products.indexWhere((p) => p.id == _editingProduct!.id);
      if (index != -1) {
        _products[index] = _editingProduct!.copyWith(
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          price: double.tryParse(priceController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
          status: _status,
        );
      }
    } else {
      final newId = _products.isEmpty ? 1 : _products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
      _products.add(Product(
        id: newId, name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.tryParse(priceController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
        status: _status,
      ));
    }

    if (context.mounted) {
      SnackBarUtils.showSnackBar(context, isUpdating ? "Product updated successfully!" : "Product created successfully!");
    }
    _isSaving = false;
    setAdding(false);
    return true;
  }

  Future<void> deleteProduct(int id) async {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> deleteSelectedProducts() async {
    if (_selectedIds.isEmpty) return;
    _products.removeWhere((p) => _selectedIds.contains(p.id));
    _selectedIds.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
