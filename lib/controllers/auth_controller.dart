import 'package:admin/data/mock_data.dart';
import 'package:admin/models/management_model.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _currentUser != null;

  /// Snackbar / general errors
  String? errorMessage;

  /// Field-level errors
  String? emailServerError;
  String? passwordServerError;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void clearErrors() {
    errorMessage = null;
    emailServerError = null;
    passwordServerError = null;
    notifyListeners();
  }

  void clearEmailServerError() {
    if (emailServerError != null) {
      emailServerError = null;
      notifyListeners();
    }
  }

  void clearPasswordServerError() {
    if (passwordServerError != null) {
      passwordServerError = null;
      notifyListeners();
    }
  }

  void clearGeneralError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  /// Initialize — no session loading needed, app starts unauthenticated
  /// so login screen shows first.
  Future<void> initAuth() async {
    // No-op: user will see login screen and tap login button
  }

  /// Instant login — always succeeds with hardcoded admin user.
  Future<bool> login() async {
    _isLoading = true;
    notifyListeners();

    clearErrors();

    // Small delay to show loading animation on login screen
    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = MockData.adminUser;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> logout() async {
    _currentUser = null;
    clearErrors();
    emailController.clear();
    passwordController.clear();
    notifyListeners();
    return true;
  }

  /// No-op — session refresh not needed for mock data.
  Future<void> refreshSession() async {}
}
