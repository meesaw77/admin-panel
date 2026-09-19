import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

mixin ImagePickerMixin on ChangeNotifier {
  File? _pickedImage;
  Uint8List? _webImage;

  File? get pickedImage => _pickedImage;
  Uint8List? get webImage => _webImage;

  bool get hasImage => _webImage != null || _pickedImage != null;

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

  void clearImage() {
    _pickedImage = null;
    _webImage = null;
    notifyListeners();
  }

  // Helper to set image state from external (e.g. when editing)
  void setImageState({File? file, Uint8List? web}) {
    _pickedImage = file;
    _webImage = web;
    notifyListeners();
  }
}
