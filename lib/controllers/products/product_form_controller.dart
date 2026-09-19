import 'dart:io';
import 'package:flutter/material.dart';

class ProductFormController extends ChangeNotifier {
  String _contentType = "product";
  File? _pickedImage;
  bool _isUploading = false;

  String get contentType => _contentType;
  File? get pickedImage => _pickedImage;
  bool get isUploading => _isUploading;

  void setContentType(String type) {
    if (_contentType == type) return;
    _contentType = type;
    notifyListeners();
  }

  void setPickedImage(File? image) {
    _pickedImage = image;
    notifyListeners();
  }

  void setUploading(bool value) {
    if (_isUploading == value) return;
    _isUploading = value;
    notifyListeners();
  }

  void reset() {
    _contentType = "product";
    _pickedImage = null;
    _isUploading = false;
    notifyListeners();
  }
}
