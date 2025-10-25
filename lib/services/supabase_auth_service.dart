import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/error_handler.dart';

/// Supabase authentication service
class SupabaseAuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  SupabaseAuthService() {
    _initializeAuth();
  }

  /// Initialize authentication and listen to auth state changes
  void _initializeAuth() {
    _currentUser = SupabaseConfig.currentUser;

    // Listen to auth state changes
    SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _currentUser = session.user;
        _error = null;
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _error = null;
      }

      notifyListeners();
    });
  }

  /// Sign up with email and password
  Future<Result<AuthResponse>> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      setLoading(true);
      clearError();

      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      if (response.user != null) {
        _currentUser = response.user;
        notifyListeners();
      }

      return Result.success(response);
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      setError(errorMessage);
      return Result.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Sign up failed: ${e.toString()}';
      setError(errorMessage);
      return Result.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Sign in with email and password
  Future<Result<AuthResponse>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      setLoading(true);
      clearError();

      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        notifyListeners();
      }

      return Result.success(response);
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      setError(errorMessage);
      return Result.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Sign in failed: ${e.toString()}';
      setError(errorMessage);
      return Result.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Sign in with Google
  Future<Result<bool>> signInWithGoogle() async {
    try {
      setLoading(true);
      clearError();

      await SupabaseConfig.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.smartbite://login-callback/',
      );

      return Result.success(true);
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      setError(errorMessage);
      return Result.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Google sign in failed: ${e.toString()}';
      setError(errorMessage);
      return Result.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Sign in with Apple
  Future<Result<bool>> signInWithApple() async {
    try {
      setLoading(true);
      clearError();

      await SupabaseConfig.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.smartbite://login-callback/',
      );

      return Result.success(true);
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      setError(errorMessage);
      return Result.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Apple sign in failed: ${e.toString()}';
      setError(errorMessage);
      return Result.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Sign out
  Future<Result<bool>> signOut() async {
    try {
      setLoading(true);
      clearError();

      await SupabaseConfig.client.auth.signOut();
      _currentUser = null;
      notifyListeners();

      return Result.success(true);
    } catch (e) {
      final errorMessage = 'Sign out failed: ${e.toString()}';
      setError(errorMessage);
      return Result.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Reset password
  Future<Result<bool>> resetPassword(String email) async {
    try {
      setLoading(true);
      clearError();

      await SupabaseConfig.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.smartbite://reset-password/',
      );

      return Result.success(true);
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      setError(errorMessage);
      return Result.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Password reset failed: ${e.toString()}';
      setError(errorMessage);
      return Result.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Update password
  Future<Result<bool>> updatePassword(String newPassword) async {
    try {
      setLoading(true);
      clearError();

      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return Result.success(true);
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      setError(errorMessage);
      return Result.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Password update failed: ${e.toString()}';
      setError(errorMessage);
      return Result.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Update user profile
  Future<Result<Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> updates,
  ) async {
    try {
      setLoading(true);
      clearError();

      final response = await SupabaseConfig.client.auth.updateUser(
        UserAttributes(data: updates),
      );

      if (response.user != null) {
        _currentUser = response.user;
        notifyListeners();
      }

      return Result.success(response.user?.userMetadata ?? {});
    } on AuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.message);
      setError(errorMessage);
      return Result.error(errorMessage);
    } catch (e) {
      final errorMessage = 'Profile update failed: ${e.toString()}';
      setError(errorMessage);
      return Result.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Get user profile from database
  Future<Result<Map<String, dynamic>>> getUserProfile() async {
    try {
      if (_currentUser == null) {
        return Result.error('User not authenticated');
      }

      final response = await SupabaseConfig.client
          .from('users')
          .select()
          .eq('id', _currentUser!.id)
          .single();

      return Result.success(response);
    } catch (e) {
      final errorMessage = 'Failed to get user profile: ${e.toString()}';
      setError(errorMessage);
      return Result.error(errorMessage);
    }
  }

  /// Create user profile in database
  Future<Result<Map<String, dynamic>>> createUserProfile(
    Map<String, dynamic> userData,
  ) async {
    try {
      if (_currentUser == null) {
        return Result.error('User not authenticated');
      }

      final profileData = {
        'id': _currentUser!.id,
        'email': _currentUser!.email,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        ...userData,
      };

      final response = await SupabaseConfig.client
          .from('users')
          .insert(profileData)
          .select()
          .single();

      return Result.success(response);
    } catch (e) {
      final errorMessage = 'Failed to create user profile: ${e.toString()}';
      setError(errorMessage);
      return Result.error(errorMessage);
    }
  }

  /// Update user profile in database
  Future<Result<Map<String, dynamic>>> updateUserProfile(
    Map<String, dynamic> updates,
  ) async {
    try {
      if (_currentUser == null) {
        return Result.error('User not authenticated');
      }

      final updateData = {
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await SupabaseConfig.client
          .from('users')
          .update(updateData)
          .eq('id', _currentUser!.id)
          .select()
          .single();

      return Result.success(response);
    } catch (e) {
      final errorMessage = 'Failed to update user profile: ${e.toString()}';
      setError(errorMessage);
      return Result.error(errorMessage);
    }
  }

  /// Get user-friendly error messages
  String _getAuthErrorMessage(String message) {
    switch (message) {
      case 'Invalid login credentials':
        return 'Invalid email or password. Please try again.';
      case 'Email not confirmed':
        return 'Please check your email and click the confirmation link.';
      case 'User already registered':
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

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
