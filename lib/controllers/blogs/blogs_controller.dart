import 'package:flutter/material.dart';
import 'package:admin/data/mock_data.dart';
import 'package:admin/models/blog_model.dart';
import 'package:admin/mixins/image_picker_mixin.dart';
import 'package:admin/utils/snack_bar_utils.dart';

class BlogsController extends ChangeNotifier with ImagePickerMixin {
  // Data State
  List<Blog> _blogs = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isAdding = false;

  // Search and Selection
  String _searchQuery = "";
  final List<int> _selectedIds = [];

  // Form State
  Blog? _editingBlog;
  String _status = "Published";
  String? _selectedService;
  String _currentView = "All Blogs";

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  // Getters
  List<Blog> get blogs => _blogs;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isAdding => _isAdding;
  Blog? get editingBlog => _editingBlog;
  String get status => _status;
  String? get selectedService => _selectedService;
  String get currentView => _currentView;
  String get searchQuery => _searchQuery;
  List<int> get selectedIds => _selectedIds;
  bool get isPollingActive => false;

  List<Blog> get filteredBlogs {
    if (_searchQuery.isEmpty) return _blogs;
    return _blogs
        .where((b) => b.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  BlogsController() {
    fetchBlogs();
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

  void setService(String? value) {
    _selectedService = value;
    notifyListeners();
  }

  void setCurrentView(String view) {
    _currentView = view;
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
      _selectedIds.addAll(filteredBlogs.map((b) => b.id));
    }
    notifyListeners();
  }

  void editBlog(Blog blog) {
    _editingBlog = blog;
    titleController.text = blog.title;
    descriptionController.text = blog.description ?? "";
    linkController.text = blog.link ?? "";
    _selectedService = (blog.category != null && blog.category!.isNotEmpty) 
        ? blog.category 
        : null;
    _status = (blog.status.isNotEmpty) ? blog.status : "Draft";
    _isAdding = true;
    setImageState(file: null, web: null);
    notifyListeners();
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    linkController.clear();
    _status = "Published";
    _selectedService = null;
    _editingBlog = null;
    clearImage();
    notifyListeners();
  }

  @override
  void clearImage() {
    super.clearImage();
    if (_editingBlog != null) {
      _editingBlog = _editingBlog!.copyWith(clearImage: true);
    }
    notifyListeners();
  }

  // Polling stubs
  void startPolling() {}
  void stopPolling() {}

  // ---------------- LOCAL DATA OPERATIONS ----------------

  Future<void> fetchBlogs({bool skipLoading = false}) async {
    if (!skipLoading) {
      _isLoading = true;
      notifyListeners();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (_blogs.isEmpty) {
      _blogs = List.from(MockData.blogs);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveBlog(BuildContext context) async {
    if (titleController.text.trim().isEmpty) {
      SnackBarUtils.showSnackBar(context, "Title is required", isError: true);
      return false;
    }

    _isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final bool isUpdating = _editingBlog != null;

    if (isUpdating) {
      final index = _blogs.indexWhere((b) => b.id == _editingBlog!.id);
      if (index != -1) {
        _blogs[index] = _editingBlog!.copyWith(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          category: _selectedService ?? "",
          status: _status,
          link: linkController.text.trim(),
        );
      }
    } else {
      final newId = _blogs.isEmpty ? 1 : _blogs.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;
      _blogs.add(Blog(
        id: newId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: _selectedService,
        status: _status,
        link: linkController.text.trim(),
      ));
    }

    if (context.mounted) {
      SnackBarUtils.showSnackBar(
        context,
        isUpdating ? "Blog updated successfully!" : "Blog created successfully!",
      );
    }

    _isSaving = false;
    setAdding(false);
    return true;
  }

  Future<void> deleteBlog(int id) async {
    _blogs.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  Future<void> deleteSelectedBlogs() async {
    if (_selectedIds.isEmpty) return;
    _blogs.removeWhere((b) => _selectedIds.contains(b.id));
    _selectedIds.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }
}
