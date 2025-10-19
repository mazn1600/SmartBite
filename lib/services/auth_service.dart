import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
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
        _currentUser = User.fromJson(userData);
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
      final databaseService = DatabaseService();
      final user = await databaseService.authenticateUser(email, password);

      if (user != null) {
        _currentUser = user;
        _token = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';

        // Save to local storage
        await _saveUserData();

        _setLoading(false);
        return true;
      } else {
        _setError('Invalid email or password');
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
      final databaseService = DatabaseService();

      // Create user object
      final user = User(
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

      // Register user in database
      final success = await databaseService.registerUser(user, password);

      if (success) {
        _currentUser = user;
        _token = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';

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
      _setError('Registration failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _clearError();

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
    await prefs.remove(AppConstants.userDataKey);

    notifyListeners();
  }

  Future<void> updateProfile(User updatedUser) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = updatedUser.copyWith(updatedAt: DateTime.now());
      await _saveUserData();

      _setLoading(false);
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
