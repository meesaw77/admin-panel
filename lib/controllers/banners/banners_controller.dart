// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:admin/models/banner_model.dart';
// import 'package:admin/services/api_service.dart';
// import 'package:admin/utils/snack_bar_utils.dart';
// import 'package:admin/mixins/image_picker_mixin.dart';

// class BannersController extends ChangeNotifier with ImagePickerMixin {
//   final ApiService _apiService = ApiService();

//   // Data State
//   List<BannerModel> _banners = [];
//   bool _isLoading = false;
//   bool _isSaving = false;
//   bool _isAdding = false;

//   // Search and Selection
//   final List<int> _selectedIds = [];
//   Timer? _pollingTimer;

//   // Form State
//   BannerModel? _editingBanner;
//   String _status = "Published";
//   String _type = "General";

//   // Controllers
//   final TextEditingController titleController = TextEditingController();

//   // Getters
//   List<BannerModel> get banners => _banners;
//   bool get isLoading => _isLoading;
//   bool get isSaving => _isSaving;
//   bool get isAdding => _isAdding;
//   BannerModel? get editingBanner => _editingBanner;
//   String get status => _status;
//   String get type => _type;
//   List<int> get selectedIds => _selectedIds;
//   bool get isPollingActive => _pollingTimer != null;

//   // Constructor
//   BannersController() {
//     fetchBanners();
//   }

//   // ---------------- UI ACTIONS ----------------

//   void setAdding(bool value) {
//     _isAdding = value;
//     if (!value) clearForm();
//     notifyListeners();
//   }

//   void setStatus(String value) {
//     _status = value;
//     notifyListeners();
//   }

//   void setType(String value) {
//     _type = value;
//     notifyListeners();
//   }

//   void toggleSelection(int id) {
//     if (_selectedIds.contains(id)) {
//       _selectedIds.remove(id);
//     } else {
//       _selectedIds.add(id);
//     }
//     notifyListeners();
//   }

//   void selectAll(bool select) {
//     _selectedIds.clear();
//     if (select) {
//       _selectedIds.addAll(_banners.map((b) => b.id));
//     }
//     notifyListeners();
//   }

//   void editBanner(BannerModel banner) {
//     _editingBanner = banner;
//     titleController.text = banner.title;
//     _status = banner.status;
//     _type = banner.type;

//     _isAdding = true;
//     setImageState(file: null, web: null);
//     notifyListeners();
//   }

//   void clearForm() {
//     titleController.clear();
//     _editingBanner = null;
//     _type = "General";
//     clearImage();
//     notifyListeners();
//   }

//   @override
//   void clearImage() {
//     super.clearImage();
//     if (_editingBanner != null) {
//       _editingBanner = _editingBanner!.copyWith(clearImage: true);
//     }
//     notifyListeners();
//   }

//   // ---------------- POLLING ----------------

//   void startPolling() {
//     stopPolling();
//     _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       fetchBanners(skipLoading: true);
//     });
//   }

//   void stopPolling() {
//     _pollingTimer?.cancel();
//     _pollingTimer = null;
//   }

//   // ---------------- API OPERATIONS ----------------

//   Future<void> fetchBanners({bool skipLoading = false}) async {
//     if (!skipLoading) {
//       _isLoading = true;
//       notifyListeners();
//     }
//     try {
//       final response = await _apiService.get("banners.php");
      
//       List<dynamic> listData = [];
//       if (response is List) {
//         listData = response;
//       } else if (response is Map) {
//         listData = response['data'] ?? response['banners'] ?? (response.containsKey('id') ? [response] : []);
//       }

//       final List<BannerModel> loadedBanners = [];
//       for (var item in listData) {
//         try {
//           loadedBanners.add(BannerModel.fromJson(item));
//         } catch (e) {
//           debugPrint("Error parsing banner: $e");
//         }
//       }
      
//       _banners = loadedBanners;
//     } catch (e) {
//       debugPrint("Error fetching banners: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> saveBanner(BuildContext context) async {
//     if (titleController.text.isEmpty) {
//       SnackBarUtils.showSnackBar(context, "Title is required", isError: true);
//       return false;
//     }

//     _isSaving = true;
//     notifyListeners();

//     try {
//       final bool isPublished = _status == "Published";

//       final fields = {
//         "title": titleController.text.trim(),
//         "type": _type,
//         "active": isPublished ? "1" : "0",
//       };

//       if (_editingBanner != null) {
//         fields["id"] = _editingBanner!.id.toString();

//         // Handle image logic
//         if (!hasImage) {
//           // If explicitly cleared (image is null in model), send empty string to signal removal
//           // If not cleared, preserve existing image
//           fields["imageUrl"] = _editingBanner!.image ?? "";
//         }
//       }

//       // ✅ Use correct postMultipart signature
//       await _apiService.postMultipart(
//         "banners.php",
//         fields,
//         imageFile: pickedImage,
//         webImageBytes: webImage,
//       );

//       final isUpdating = _editingBanner != null;
//       await fetchBanners(skipLoading: true);

//       if (context.mounted) {
//         SnackBarUtils.showSnackBar(
//           context,
//           isUpdating
//               ? "Banner updated successfully!"
//               : "Banner created successfully!",
//         );
//       }

//       setAdding(false);
//       return true;
//     } catch (e) {
//       debugPrint("Error saving banner: $e");
//       if (context.mounted) {
//         SnackBarUtils.showSnackBar(context, "Error: $e", isError: true);
//       }
//       return false;
//     } finally {
//       _isSaving = false;
//       notifyListeners();
//     }
//   }

//   Future<void> deleteBanner(int id) async {
//     try {
//       await _apiService.delete("banners.php?id=$id");
//       _banners.removeWhere((b) => b.id == id);
//       notifyListeners();
//     } catch (e) {
//       debugPrint("Error deleting banner: $e");
//       fetchBanners();
//     }
//   }

//   Future<void> deleteSelectedBanners() async {
//     if (_selectedIds.isEmpty) return;
//     _isSaving = true;
//     notifyListeners();
//     try {
//       for (var id in _selectedIds) {
//         await _apiService.delete("banners.php?id=$id");
//       }
//       _selectedIds.clear();
//       await fetchBanners(skipLoading: true);
//     } catch (e) {
//       debugPrint("Error deleting selected banners: $e");
//     } finally {
//       _isSaving = false;
//       notifyListeners();
//     }
//   }

//   @override
//   void dispose() {
//     titleController.dispose();
//     stopPolling();
//     super.dispose();
//   }
// }
