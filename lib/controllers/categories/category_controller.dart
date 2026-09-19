import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:admin/data/mock_data.dart';
import 'package:admin/models/category_model.dart';
import 'package:admin/utils/snack_bar_utils.dart';

class CategoryController extends ChangeNotifier {
  // Data State
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isAdding = false;

  // Search and Selection
  String _searchQuery = "";
  final List<int> _selectedIds = [];

  // Form State
  Category? _editingCategory;
  File? _pickedImage;
  Uint8List? _webImage;
  String _status = "Published";

  final TextEditingController titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isAdding => _isAdding;
  Category? get editingCategory => _editingCategory;
  File? get pickedImage => _pickedImage;
  Uint8List? get webImage => _webImage;
  String get status => _status;
  String get searchQuery => _searchQuery;
  List<int> get selectedIds => _selectedIds;
  bool get isPollingActive => false;

  List<Category> get filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where((c) => c.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  CategoryController() {
    fetchCategories();
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
      _selectedIds.addAll(filteredCategories.map((c) => c.id));
    }
    notifyListeners();
  }

  void editCategory(Category category) {
    _editingCategory = category;
    titleController.text = category.title;
    descriptionController.text = category.description ?? "";
    _status = category.status;
    _isAdding = true;
    _pickedImage = null;
    _webImage = null;
    notifyListeners();
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    _pickedImage = null;
    _webImage = null;
    _status = "Published";
    _editingCategory = null;
    notifyListeners();
  }

  void clearImage() {
    _pickedImage = null;
    _webImage = null;
    if (_editingCategory != null) {
      _editingCategory = _editingCategory!.copyWith(image: "");
    }
    notifyListeners();
  }

  // ---------------- IMAGE PICKER ----------------

  Future<void> pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          _webImage = await pickedFile.readAsBytes();
          _pickedImage = null;
        } else {
          _pickedImage = File(pickedFile.path);
          _webImage = null;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
    }
  }

  // Polling stubs
  void startPolling() {}
  void stopPolling() {}

  // ---------------- LOCAL DATA OPERATIONS ----------------

  Future<void> fetchCategories({bool skipLoading = false}) async {
    if (!skipLoading) {
      _isLoading = true;
      notifyListeners();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (_categories.isEmpty) {
      _categories = List.from(MockData.categories);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveCategory(BuildContext context) async {
    if (titleController.text.isEmpty) return false;
    _isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final bool isUpdating = _editingCategory != null;
    if (isUpdating) {
      final index = _categories.indexWhere((c) => c.id == _editingCategory!.id);
      if (index != -1) {
        _categories[index] = _editingCategory!.copyWith(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          status: _status,
        );
      }
    } else {
      final newId = _categories.isEmpty ? 1 : _categories.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
      _categories.add(Category(
        id: newId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        status: _status,
      ));
    }

    if (context.mounted) {
      SnackBarUtils.showSnackBar(
        context,
        isUpdating ? "Category updated successfully!" : "Category created successfully!",
      );
    }

    _isSaving = false;
    setAdding(false);
    return true;
  }

  Future<void> deleteCategory(int id) async {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> deleteSelectedCategories() async {
    if (_selectedIds.isEmpty) return;
    _categories.removeWhere((c) => _selectedIds.contains(c.id));
    _selectedIds.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
