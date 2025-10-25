import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_user;
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  app_user.User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;
  final DatabaseService _databaseService = DatabaseService();

  app_user.User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _token != null;

  AuthService() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.userTokenKey);
      final userDataString = prefs.getString(AppConstants.userDataKey);

      debugPrint('AuthService: Loading user data...');
      debugPrint('Token exists: ${token != null}');
      debugPrint('User data exists: ${userDataString != null}');

      if (token != null && userDataString != null) {
        _token = token;
        // Parse the JSON string back to a Map
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        _currentUser = app_user.User.fromJson(userData);
        debugPrint(
            'AuthService: User loaded successfully - ${_currentUser?.name}');
        debugPrint(
            'AuthService: User target calories - ${_currentUser?.targetCalories}');
        notifyListeners();
      } else {
        debugPrint('AuthService: No user data found in storage');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _databaseService.authenticateUser(email, password);

      if (user != null) {
        _token = DateTime.now()
            .millisecondsSinceEpoch
            .toString(); // Generate a simple token
        _currentUser = user;

        await _saveUserData();
        _setLoading(false);
        return true;
      } else {
        _setError('Invalid email or password. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required int age,
    required double height,
    required double weight,
    double? targetWeight,
    required String gender,
    required String activityLevel,
    required String goal,
    List<String> allergies = const [],
    List<String> healthConditions = const [],
    List<String> foodPreferences = const [],
    List<String> dietaryPreferences = const [],
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Check if email already exists
      final emailExists = await _databaseService.emailExists(email);
      if (emailExists) {
        _setError('An account already exists with this email address.');
        _setLoading(false);
        return false;
      }

      // Create user object
      final user = app_user.User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        age: age,
        height: height,
        weight: weight,
        targetWeight: targetWeight,
        gender: gender,
        activityLevel: activityLevel,
        goal: goal,
        allergies: allergies,
        healthConditions: healthConditions,
        foodPreferences: [
          ...foodPreferences,
          ...dietaryPreferences
        ], // Combine both lists
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user to local database
      final success = await _databaseService.registerUser(user, password);

      if (success) {
        _token = DateTime.now()
            .millisecondsSinceEpoch
            .toString(); // Generate a simple token
        _currentUser = user;

        // Save to local storage
        await _saveUserData();

        _setLoading(false);
        return true;
      } else {
        _setError('Registration failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      String errorMessage = 'Registration failed. Please try again.';

      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'An account already exists with this email address.';
      } else if (e.toString().contains('weak-password')) {
        errorMessage =
            'Password is too weak. Please choose a stronger password.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      _setError(errorMessage);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _clearError();

    // Clear local storage
    await _clearUserData();
    notifyListeners();
  }

  Future<void> updateProfile(app_user.User updatedUser) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      // Update user in local database
      final success = await _databaseService.updateUser(updatedUser);

      if (success) {
        _currentUser = updatedUser.copyWith(updatedAt: DateTime.now());
        await _saveUserData();
        _setLoading(false);
      } else {
        _setError('Profile update failed. Please try again.');
        _setLoading(false);
      }
    } catch (e) {
      _setError('Profile update failed. Please try again.');
      _setLoading(false);
    }
  }

  Future<void> _saveUserData() async {
    if (_currentUser == null || _token == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userTokenKey, _token!);
    await prefs.setString(
        AppConstants.userDataKey, jsonEncode(_currentUser!.toJson()));
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // For now, just simulate password reset
      // In a real app, you would send an email
      debugPrint('Password reset requested for: $email');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Password reset failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Validation methods
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  String? validateName(String name) {
    if (name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateAge(int age) {
    if (age < AppConstants.minAge || age > AppConstants.maxAge) {
      return 'Age must be between ${AppConstants.minAge} and ${AppConstants.maxAge}';
    }
    return null;
  }

  String? validateHeight(double height) {
    if (height < AppConstants.minHeight || height > AppConstants.maxHeight) {
      return 'Height must be between ${AppConstants.minHeight} and ${AppConstants.maxHeight} cm';
    }
    return null;
  }

  String? validateWeight(double weight) {
    if (weight < AppConstants.minWeight || weight > AppConstants.maxWeight) {
      return 'Weight must be between ${AppConstants.minWeight} and ${AppConstants.maxWeight} kg';
    }
    return null;
  }
}
