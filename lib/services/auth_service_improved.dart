import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_user;
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import 'database_service.dart';

/// Improved AuthService with comprehensive error handling and validation
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

  /// Loads user data from local storage on app startup
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.userTokenKey);
      final userDataString = prefs.getString(AppConstants.userDataKey);

      if (token != null && userDataString != null) {
        _token = token;
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        _currentUser = app_user.User.fromJson(userData);
        debugPrint(
            'AuthService: User loaded successfully - ${_currentUser?.name}');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _setError('Failed to load user data');
    }
  }

  /// Authenticates user with email and password
  Future<Result<app_user.User>> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate inputs
      final validationResult = _validateLoginInputs(email, password);
      if (validationResult != null) {
        return Result.error(validationResult);
      }

      // Authenticate with database service
      final user = await _databaseService.authenticateUser(email, password);

      if (user != null) {
        _token = _generateMockToken(user);
        _currentUser = user;
        await _saveUserData();

        debugPrint('AuthService: Login successful for ${user.name}');
        notifyListeners();
        return Result.success(user);
      } else {
        return Result.error('Invalid email or password');
      }
    } on NetworkException catch (e) {
      return Result.error('Network error: ${e.message}');
    } on DatabaseException catch (e) {
      return Result.error('Database error: ${e.message}');
    } catch (e) {
      debugPrint('AuthService: Login error: $e');
      return Result.error('Login failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Registers a new user
  Future<Result<app_user.User>> register({
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
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate inputs
      final validationResult = _validateRegistrationInputs(
        email: email,
        password: password,
        name: name,
        age: age,
        height: height,
        weight: weight,
        gender: gender,
        activityLevel: activityLevel,
        goal: goal,
      );

      if (validationResult != null) {
        return Result.error(validationResult);
      }

      // Check if email already exists
      final emailExists = await _databaseService.emailExists(email);
      if (emailExists) {
        return Result.error('Email already registered');
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
        foodPreferences: foodPreferences,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Register user in database
      final success = await _databaseService.registerUser(user, password);
      if (success) {
        _token = _generateMockToken(user);
        _currentUser = user;
        await _saveUserData();

        debugPrint('AuthService: Registration successful for ${user.name}');
        notifyListeners();
        return Result.success(user);
      } else {
        return Result.error('Registration failed. Please try again.');
      }
    } on ValidationException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error('Network error: ${e.message}');
    } on DatabaseException catch (e) {
      return Result.error('Database error: ${e.message}');
    } catch (e) {
      debugPrint('AuthService: Registration error: $e');
      return Result.error('Registration failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Updates user profile
  Future<Result<app_user.User>> updateProfile(app_user.User updatedUser) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        return Result.error('No user logged in');
      }

      // Validate updated user data
      final validationResult = _validateUserData(updatedUser);
      if (validationResult != null) {
        return Result.error(validationResult);
      }

      // Update user in database
      final success = await _databaseService.updateUser(updatedUser);
      if (success) {
        _currentUser = updatedUser;
        await _saveUserData();

        debugPrint('AuthService: Profile updated successfully');
        notifyListeners();
        return Result.success(updatedUser);
      } else {
        return Result.error('Failed to update profile');
      }
    } on ValidationException catch (e) {
      return Result.error(e.message);
    } on DatabaseException catch (e) {
      return Result.error('Database error: ${e.message}');
    } catch (e) {
      debugPrint('AuthService: Profile update error: $e');
      return Result.error('Profile update failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Logs out the current user
  Future<void> logout() async {
    try {
      _currentUser = null;
      _token = null;
      _clearError();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userTokenKey);
      await prefs.remove(AppConstants.userDataKey);

      debugPrint('AuthService: User logged out successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('AuthService: Logout error: $e');
      _setError('Logout failed');
    }
  }

  /// Saves user data to local storage
  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null && _token != null) {
        await prefs.setString(AppConstants.userTokenKey, _token!);
        await prefs.setString(
          AppConstants.userDataKey,
          jsonEncode(_currentUser!.toJson()),
        );
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
      throw DatabaseException('Failed to save user data');
    }
  }

  /// Validates login inputs
  String? _validateLoginInputs(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password are required';
    }

    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address';
    }

    if (password.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    return null;
  }

  /// Validates registration inputs
  String? _validateRegistrationInputs({
    required String email,
    required String password,
    required String name,
    required int age,
    required double height,
    required double weight,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    // Email validation
    if (email.isEmpty) return 'Email is required';
    if (!_isValidEmail(email)) return 'Please enter a valid email address';

    // Password validation
    if (password.isEmpty) return 'Password is required';
    if (password.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (password.length > AppConstants.maxPasswordLength) {
      return 'Password must be less than ${AppConstants.maxPasswordLength} characters';
    }

    // Name validation
    if (name.isEmpty) return 'Name is required';
    if (name.length < 2) return 'Name must be at least 2 characters';

    // Age validation
    if (age < AppConstants.minAge || age > AppConstants.maxAge) {
      return 'Age must be between ${AppConstants.minAge} and ${AppConstants.maxAge}';
    }

    // Height validation
    if (height < AppConstants.minHeight || height > AppConstants.maxHeight) {
      return 'Height must be between ${AppConstants.minHeight} and ${AppConstants.maxHeight} cm';
    }

    // Weight validation
    if (weight < AppConstants.minWeight || weight > AppConstants.maxWeight) {
      return 'Weight must be between ${AppConstants.minWeight} and ${AppConstants.maxWeight} kg';
    }

    // Gender validation
    if (!AppConstants.genders.contains(gender.toLowerCase())) {
      return 'Please select a valid gender';
    }

    // Activity level validation
    if (!AppConstants.activityLevels.contains(activityLevel.toLowerCase())) {
      return 'Please select a valid activity level';
    }

    // Goal validation
    if (!AppConstants.goals.contains(goal.toLowerCase())) {
      return 'Please select a valid goal';
    }

    return null;
  }

  /// Validates user data
  String? _validateUserData(app_user.User user) {
    return _validateRegistrationInputs(
      email: user.email,
      password: 'dummy', // Password not needed for profile update
      name: user.name,
      age: user.age,
      height: user.height,
      weight: user.weight,
      gender: user.gender,
      activityLevel: user.activityLevel,
      goal: user.goal,
    );
  }

  /// Validates email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Generates a mock JWT token
  String _generateMockToken(app_user.User user) {
    final header = base64Encode(utf8.encode(jsonEncode({
      'alg': 'HS256',
      'typ': 'JWT',
    })));

    final payload = base64Encode(utf8.encode(jsonEncode({
      'sub': user.id,
      'email': user.email,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp':
          (DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/
              1000),
    })));

    final signature = base64Encode(utf8.encode('mock_signature'));

    return '$header.$payload.$signature';
  }

  /// Sets loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clears error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
