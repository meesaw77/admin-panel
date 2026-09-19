import 'package:flutter/material.dart';

mixin WordCountMixin on ChangeNotifier {
  int _wordCount = 0;
  final int maxWords = 200;

  int get wordCount => _wordCount;
  bool get isDescriptionValid => _wordCount <= maxWords;

  void updateWordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _wordCount = 0;
    } else {
      _wordCount = trimmed.split(RegExp(r'\s+')).length;
    }
    notifyListeners();
  }

  void resetWordCount() {
    _wordCount = 0;
    notifyListeners();
  }
}
