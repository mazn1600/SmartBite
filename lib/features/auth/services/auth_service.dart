import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../shared/models/user.dart' as app_user;
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/error_handler.dart';

/// Consolidated authentication service using Supabase
/// Provides unified authentication interface for the app
class AuthService extends ChangeNotifier {
  app_user.User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  app_user.User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _token != null;

  AuthService() {
    _initializeAuth();
  }

  /// Initialize authentication and listen to auth state changes
  void _initializeAuth() {
    _loadCachedUser();
    _listenToAuthChanges();
  }

  /// Load cached user from local storage
  Future<void> _loadCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.userTokenKey);
      final userDataString = prefs.getString(AppConstants.userDataKey);

      if (token != null && userDataString != null) {
        _token = token;
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        _currentUser = app_user.User.fromJson(userData);
        debugPrint('AuthService: Cached user loaded - ${_currentUser?.name}');
        notifyListeners();
      }

      // Also check Supabase session
      final supabaseUser = SupabaseConfig.currentUser;
      if (supabaseUser != null && _currentUser == null) {
        // Sync with Supabase
        await _syncUserFromSupabase(supabaseUser);
      }
    } catch (e) {
      debugPrint('AuthService: Error loading cached user: $e');
    }
  }

  /// Listen to Supabase auth state changes
  void _listenToAuthChanges() {
    SupabaseConfig.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _syncUserFromSupabase(session.user);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _token = null;
        _clearError();
        await _clearUserData();
        notifyListeners();
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        _token = session.accessToken;
        await _saveUserData();
      }
    });
  }

  /// Sync user data from Supabase
  Future<void> _syncUserFromSupabase(User supabaseUser) async {
    try {
      // Try to get user profile from database
      final profileResult = await getUserProfile();
      if (profileResult.isSuccess && profileResult.data != null) {
        _currentUser = profileResult.data!;
      } else {
        // Create user from Supabase metadata
        final metadata = supabaseUser.userMetadata ?? {};
        _currentUser = app_user.User(
          id: supabaseUser.id,
          email: supabaseUser.email ?? '',
          name: metadata['name']?.toString() ??
              metadata['first_name']?.toString() ??
              'User',
          age: metadata['age'] as int? ?? 25,
          height: (metadata['height'] as num?)?.toDouble() ?? 170.0,
          weight: (metadata['weight'] as num?)?.toDouble() ?? 70.0,
          targetWeight: (metadata['target_weight'] as num?)?.toDouble(),
          gender: metadata['gender']?.toString() ?? 'male',
          activityLevel:
              metadata['activity_level']?.toString() ?? 'moderately_active',
          goal: metadata['goal']?.toString() ?? 'maintenance',
          allergies: List<String>.from(metadata['allergies'] ?? []),
          foodPreferences:
              List<String>.from(metadata['food_preferences'] ?? []),
          createdAt: DateTime.parse(supabaseUser.createdAt),
          updatedAt: DateTime.now(),
        );
      }

      _token = SupabaseConfig.client.auth.currentSession?.accessToken;
      await _saveUserData();
      notifyListeners();
    } catch (e) {
      debugPrint('AuthService: Error syncing user from Supabase: $e');
    }
  }

  /// Sign in with email and password
  Future<Result<bool>> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔐 AuthService: Starting sign in for email: ${email.trim()}');

      // Validate inputs
      final emailError = validateEmail(email);
      if (emailError != null) {
        debugPrint('❌ AuthService: Email validation failed: $emailError');
        _setError(emailError);
        _setLoading(false);
        return Result.error(emailError);
      }

      final passwordError = validatePassword(password);
      if (passwordError != null) {
        debugPrint('❌ AuthService: Password validation failed: $passwordError');
        _setError(passwordError);
        _setLoading(false);
        return Result.error(passwordError);
      }

      // Check if Supabase client is initialized
      try {
        final _ = SupabaseConfig.client;
        debugPrint('✅ AuthService: Supabase client is available');
      } catch (e) {
        debugPrint('❌ AuthService: Supabase client not initialized: $e');
        _setError('Database connection error. Please restart the app.');
        _setLoading(false);
        return Result.error(
            'Database connection error. Please restart the app.');
      }

      // Sign in with Supabase
      debugPrint('🔌 AuthService: Attempting Supabase sign in...');
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('✅ AuthService: Supabase sign in response received');

      if (response.user != null) {
        debugPrint('✅ AuthService: User authenticated, syncing user data...');
        await _syncUserFromSupabase(response.user!);
        debugPrint('✅ AuthService: User data synced successfully');
        _setLoading(false);
        return Result.success(true);
      } else {
        debugPrint('❌ AuthService: Sign in response has no user');
        _setError('Login failed. Please try again.');
        _setLoading(false);
        return Result.error('Login failed. Please try again.');
      }
    } on AuthException catch (e) {
      debugPrint('❌ AuthService: AuthException during sign in: ${e.message}');
      debugPrint('   Error details: ${e.toString()}');
      final errorMessage = _getAuthErrorMessage(e.message);
      _setError(errorMessage);
      _setLoading(false);
      return Result.error(errorMessage);
    } on Exception catch (e) {
      debugPrint('❌ AuthService: Exception during sign in: $e');
      debugPrint('   Exception type: ${e.runtimeType}');
      _setError(
          'Login failed. Please check your internet connection and try again.');
      _setLoading(false);
      return Result.error(
          'Login failed. Please check your internet connection and try again.');
    } catch (e, stackTrace) {
      debugPrint('❌ AuthService: Unexpected error during sign in: $e');
      debugPrint('   Stack trace: $stackTrace');
      _setError('Login failed. Please try again.');
      _setLoading(false);
      return Result.error('Login failed. Please try again.');
    }
  }

  /// Login with email and password (legacy method for compatibility)
  Future<bool> login(String email, String password) async {
    final result = await signIn(email: email, password: password);
    return result.isSuccess;
  }

  /// Register new user
  Future<Result<bool>> register({
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
    List<String> foodPreferences = const [],
    List<String> dietaryPreferences = const [],
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate inputs
      final validationError = _validateRegistrationInputs(
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
      if (validationError != null) {
        _setError(validationError);
        _setLoading(false);
        return Result.error(validationError);
      }

      // Prepare user metadata for Supabase
      final userData = {
        'name': name,
        'age': age,
        'height': height,
        'weight': weight,
        if (targetWeight != null) 'target_weight': targetWeight,
        'gender': gender,
        'activity_level': activityLevel,
        'goal': goal,
        'allergies': allergies,
        'food_preferences': [...foodPreferences, ...dietaryPreferences],
      };

      // Sign up with Supabase
      final response = await SupabaseConfig.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: userData,
      );

      if (response.user != null) {
        // Create user profile in database
        final userProfile = app_user.User(
          id: response.user!.id,
          email: email.trim(),
          name: name,
          age: age,
          height: height,
          weight: weight,
          targetWeight: targetWeight,
          gender: gender,
          activityLevel: activityLevel,
          goal: goal,
          allergies: allergies,
          foodPreferences: [...foodPreferences, ...dietaryPreferences],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save profile to Supabase database
        final createResult = await createUserProfile(userProfile);
        if (createResult.isSuccess) {
          _currentUser = userProfile;
          _token = SupabaseConfig.client.auth.currentSession?.accessToken;
          await _saveUserData();
          _setLoading(false);
          return Result.success(true);
        } else {
          _setError(createResult.error ?? 'Registration failed');
          _setLoading(false);
          return Result.error(createResult.error ?? 'Registration failed');
        }
      } else {
        _setError('Registration failed. Please try again.');
        _setLoading(false);
        return Result.error('Registration failed. Please try again.');
      }
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      _setError(errorMessage);
      _setLoading(false);
      return Result.error(errorMessage);
    } catch (e) {
      _setError('Registration failed. Please try again.');
      _setLoading(false);
      return Result.error('Registration failed. Please try again.');
    }
  }

  /// Sign in with Google
  Future<Result<bool>> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      await SupabaseConfig.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.smartbite://login-callback/',
      );

      return Result.success(true);
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      _setError(errorMessage);
      return Result.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Google sign in failed: ${e.toString()}';
      _setError(errorMessage);
      return Result.error(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Apple
  Future<Result<bool>> signInWithApple() async {
    try {
      _setLoading(true);
      _clearError();

      await SupabaseConfig.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.smartbite://login-callback/',
      );

      return Result.success(true);
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      _setError(errorMessage);
      return Result.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Apple sign in failed: ${e.toString()}';
      _setError(errorMessage);
      return Result.error(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _setLoading(true);
      await SupabaseConfig.client.auth.signOut();
      _currentUser = null;
      _token = null;
      _clearError();
      await _clearUserData();
      notifyListeners();
    } catch (e) {
      debugPrint('AuthService: Logout error: $e');
      _setError('Logout failed');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<void> updateProfile(app_user.User updatedUser) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      // Update in Supabase database
      final updateData = {
        'name': updatedUser.name,
        'age': updatedUser.age,
        'height': updatedUser.height,
        'weight': updatedUser.weight,
        if (updatedUser.targetWeight != null)
          'target_weight': updatedUser.targetWeight,
        'gender': updatedUser.gender,
        'activity_level': updatedUser.activityLevel,
        'goal': updatedUser.goal,
        'allergies': updatedUser.allergies,
        'food_preferences': updatedUser.foodPreferences,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await SupabaseConfig.client
          .from(SupabaseTables.users)
          .update(updateData)
          .eq('id', _currentUser!.id)
          .select()
          .single();

      _currentUser = updatedUser.copyWith(updatedAt: DateTime.now());
      await _saveUserData();
      _setLoading(false);
    } catch (e) {
      _setError('Profile update failed. Please try again.');
      _setLoading(false);
    }
  }

  /// Reset password
  Future<Result<bool>> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final emailError = validateEmail(email);
      if (emailError != null) {
        _setError(emailError);
        _setLoading(false);
        return Result.error(emailError);
      }

      await SupabaseConfig.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.smartbite://reset-password/',
      );

      _setLoading(false);
      return Result.success(true);
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      _setError(errorMessage);
      _setLoading(false);
      return Result.error(errorMessage);
    } catch (e) {
      _setError('Password reset failed. Please try again.');
      _setLoading(false);
      return Result.error('Password reset failed. Please try again.');
    }
  }

  /// Get user profile from database
  Future<Result<app_user.User>> getUserProfile() async {
    try {
      if (_currentUser == null) {
        final supabaseUser = SupabaseConfig.currentUser;
        if (supabaseUser == null) {
          return Result.error('User not authenticated');
        }
        // Use Supabase user ID - explicitly select all columns to avoid 406 error
        try {
          debugPrint('🔍 AuthService: Fetching user profile from database...');
          final response = await SupabaseConfig.client
              .from(SupabaseTables.users)
              .select('*')
              .eq('id', supabaseUser.id)
              .single();

          debugPrint('✅ AuthService: User profile fetched from database');

          // Map database schema to app schema
          final user = _mapDatabaseUserToAppUser(response, supabaseUser);
          return Result.success(user);
        } catch (dbError) {
          // If database query fails, fall back to creating user from Supabase metadata
          debugPrint(
              '⚠️  AuthService: Database query failed, using metadata fallback: $dbError');
          final metadata = supabaseUser.userMetadata ?? {};
          final user = app_user.User(
            id: supabaseUser.id,
            email: supabaseUser.email ?? '',
            name: metadata['name']?.toString() ??
                metadata['first_name']?.toString() ??
                'User',
            age: metadata['age'] as int? ?? 25,
            height: (metadata['height'] as num?)?.toDouble() ?? 170.0,
            weight: (metadata['weight'] as num?)?.toDouble() ?? 70.0,
            targetWeight: (metadata['target_weight'] as num?)?.toDouble(),
            gender: metadata['gender']?.toString() ?? 'male',
            activityLevel:
                metadata['activity_level']?.toString() ?? 'moderately_active',
            goal: metadata['goal']?.toString() ?? 'maintenance',
            allergies: List<String>.from(metadata['allergies'] ?? []),
            foodPreferences:
                List<String>.from(metadata['food_preferences'] ?? []),
            createdAt: DateTime.parse(supabaseUser.createdAt),
            updatedAt: DateTime.now(),
          );
          return Result.success(user);
        }
      }
      return Result.success(_currentUser!);
    } catch (e) {
      debugPrint('❌ AuthService: Error getting user profile: $e');
      return Result.error('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Map database user schema to app user schema
  app_user.User _mapDatabaseUserToAppUser(
    Map<String, dynamic> dbUser,
    User supabaseUser,
  ) {
    // Calculate age from date_of_birth if available
    int age = 25;
    if (dbUser['date_of_birth'] != null) {
      try {
        final dob = DateTime.parse(dbUser['date_of_birth']);
        final now = DateTime.now();
        age = now.year - dob.year;
        if (now.month < dob.month ||
            (now.month == dob.month && now.day < dob.day)) {
          age--;
        }
      } catch (e) {
        debugPrint('⚠️  AuthService: Could not parse date_of_birth: $e');
      }
    } else if (dbUser['age'] != null) {
      age =
          dbUser['age'] is int ? dbUser['age'] : (dbUser['age'] as num).toInt();
    }

    // Combine first_name and last_name into name
    String name = 'User';
    if (dbUser['first_name'] != null || dbUser['last_name'] != null) {
      final firstName = dbUser['first_name']?.toString() ?? '';
      final lastName = dbUser['last_name']?.toString() ?? '';
      name = [firstName, lastName].where((n) => n.isNotEmpty).join(' ').trim();
      if (name.isEmpty) name = 'User';
    } else if (dbUser['name'] != null) {
      name = dbUser['name'].toString();
    }

    // Map dietary_preferences to foodPreferences
    List<String> foodPreferences = [];
    if (dbUser['dietary_preferences'] != null) {
      foodPreferences = List<String>.from(dbUser['dietary_preferences']);
    } else if (dbUser['food_preferences'] != null) {
      foodPreferences = List<String>.from(dbUser['food_preferences']);
    }

    return app_user.User(
      id: dbUser['id'] ?? supabaseUser.id,
      email: dbUser['email'] ?? supabaseUser.email ?? '',
      name: name,
      age: age,
      height: (dbUser['height'] as num?)?.toDouble() ?? 170.0,
      weight: (dbUser['weight'] as num?)?.toDouble() ?? 70.0,
      targetWeight: null, // Not in database schema
      gender: dbUser['gender']?.toString() ?? 'male',
      activityLevel:
          dbUser['activity_level']?.toString() ?? 'moderately_active',
      goal: dbUser['goal']?.toString() ?? 'maintenance',
      allergies: List<String>.from(dbUser['allergies'] ?? []),
      foodPreferences: foodPreferences,
      createdAt: dbUser['created_at'] != null
          ? DateTime.parse(dbUser['created_at'])
          : DateTime.parse(supabaseUser.createdAt),
      updatedAt: dbUser['updated_at'] != null
          ? DateTime.parse(dbUser['updated_at'])
          : DateTime.now(),
    );
  }

  /// Create user profile in database
  Future<Result<Map<String, dynamic>>> createUserProfile(
    app_user.User user,
  ) async {
    try {
      final profileData = {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'age': user.age,
        'height': user.height,
        'weight': user.weight,
        if (user.targetWeight != null) 'target_weight': user.targetWeight,
        'gender': user.gender,
        'activity_level': user.activityLevel,
        'goal': user.goal,
        'allergies': user.allergies,
        'food_preferences': user.foodPreferences,
        'created_at': user.createdAt.toIso8601String(),
        'updated_at': user.updatedAt.toIso8601String(),
      };

      await SupabaseConfig.client
          .from(SupabaseTables.users)
          .insert(profileData);

      return Result.success(profileData);
    } catch (e) {
      return Result.error('Failed to create user profile: ${e.toString()}');
    }
  }

  /// Save user data to local storage
  Future<void> _saveUserData() async {
    if (_currentUser == null || _token == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userTokenKey, _token!);
      await prefs.setString(
          AppConstants.userDataKey, jsonEncode(_currentUser!.toJson()));
    } catch (e) {
      debugPrint('AuthService: Error saving user data: $e');
    }
  }

  /// Clear user data from local storage
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userTokenKey);
      await prefs.remove(AppConstants.userDataKey);
    } catch (e) {
      debugPrint('AuthService: Error clearing user data: $e');
    }
  }

  /// Get user-friendly error messages
  String _getAuthErrorMessage(String message) {
    switch (message) {
      case 'Invalid login credentials':
      case 'Invalid credentials':
        return 'Invalid email or password. Please try again.';
      case 'Email not confirmed':
        return 'Please check your email and click the confirmation link.';
      case 'User already registered':
      case 'User already exists':
        return 'An account with this email already exists.';
      case 'Password should be at least 6 characters':
        return 'Password must be at least 6 characters long.';
      case 'Invalid email':
        return 'Please enter a valid email address.';
      case 'Signup is disabled':
        return 'Account creation is currently disabled.';
      case 'Email rate limit exceeded':
        return 'Too many requests. Please try again later.';
      default:
        return message;
    }
  }

  /// Validate registration inputs
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
    final emailError = validateEmail(email);
    if (emailError != null) return emailError;

    final passwordError = validatePassword(password);
    if (passwordError != null) return passwordError;

    final nameError = validateName(name);
    if (nameError != null) return nameError;

    final ageError = validateAge(age);
    if (ageError != null) return ageError;

    final heightError = validateHeight(height);
    if (heightError != null) return heightError;

    final weightError = validateWeight(weight);
    if (weightError != null) return weightError;

    return null;
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
}
