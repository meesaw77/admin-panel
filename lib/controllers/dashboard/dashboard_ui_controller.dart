import 'package:flutter/material.dart';

class DashboardUIController extends ChangeNotifier {
  // StatCard hover state
  final Map<String, bool> _hoverStates = {};

  bool isHovered(String key) => _hoverStates[key] ?? false;

  void setHovered(String key, bool value) {
    if (_hoverStates[key] == value) return;
    _hoverStates[key] = value;
    notifyListeners();
  }

  // DateSelectorHeader state
  int _selectedDateIndex = (DateTime.now().weekday <= 6)
      ? DateTime.now().weekday - 1
      : 0;
  String _selectedDateString = DateTime.now().toIso8601String().split('T')[0];

  int get selectedDateIndex => _selectedDateIndex;
  String get selectedDateString => _selectedDateString;

  void setSelectedDateIndex(int index) {
    if (_selectedDateIndex == index) return;
    _selectedDateIndex = index;
    notifyListeners();
  }

  void setSelectedDateString(String date) {
    if (_selectedDateString == date) return;
    _selectedDateString = date;
    notifyListeners();
  }
}
