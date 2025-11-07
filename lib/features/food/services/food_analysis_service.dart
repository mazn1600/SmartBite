import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/food_analysis_api_config.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/models/food_analysis_models.dart';
import '../../../shared/models/intrest_api_token.dart';
import '../../../shared/services/intrest_token_service.dart';
import '../../../shared/utils/error_handler.dart';

/// Food Analysis Service
///
/// A comprehensive service for integrating with the Food Analysis API.
/// Provides automatic authentication, token management, and all 11 API endpoints.
///
/// **Features:**
/// - Automatic authentication on first API call
/// - Token persistence across app restarts
/// - Automatic token refresh on expiration
/// - Retry logic for network errors
/// - Comprehensive error handling using Result<T> pattern
///
/// **Usage Example:**
/// ```dart
/// // Get service instance (singleton)
/// final service = FoodAnalysisService();
///
/// // Initialize (optional - auto-initializes on first API call)
/// await service.initialize();
///
/// // Use any API method
/// final result = await service.extractIngredients('Grilled Chicken Salad');
/// result.onSuccess((response) {
///   print('Ingredients: ${response.ingredients.map((i) => i.name).join(', ')}');
/// });
/// result.onError((error) {
///   print('Error: $error');
/// });
///
/// // Full pipeline analysis
/// final fullResult = await service.fullPipelineAnalysis(
///   'Mediterranean Quinoa Bowl',
///   dietTypes: ['vegan', 'vegetarian'],
/// );
/// ```
///
/// **Authentication:**
/// - Authentication is handled automatically
/// - Tokens are stored securely in SharedPreferences
/// - Expired tokens are refreshed automatically
/// - 401 errors trigger automatic re-authentication
class FoodAnalysisService {
  static final FoodAnalysisService _instance = FoodAnalysisService._internal();
  factory FoodAnalysisService() => _instance;
  FoodAnalysisService._internal();

  // ========== Private Fields ==========
  String? _accessToken;
  String? _refreshToken;
  int? _tokenExpiresAt; // milliseconds timestamp

  // ========== Public Methods ==========

  /// Initialize service and load stored tokens from SharedPreferences
  ///
  /// This method is optional - the service will auto-initialize on first API call.
  /// Call this explicitly if you want to pre-load tokens.
  Future<void> initialize() async {
    await _loadTokens();
  }

  // ========== Authentication Methods ==========

  /// Login to the API using stored credentials
  ///
  /// Authenticates with the API and stores access/refresh tokens.
  /// This is called automatically when needed, but can be called manually.
  ///
  /// Returns [Result<LoginResponse>] with tokens or error message.
  Future<Result<LoginResponse>> login() async {
    final stopwatch = Stopwatch()..start();
    try {
      _log('Login', 'Attempting to authenticate...');

      // For direct API calls, credentials must be provided
      // Backend proxy handles authentication server-side, so login is not called
      if (!FoodAnalysisApiConfig.useBackendProxy) {
        final username = FoodAnalysisApiConfig.username;
        final password = FoodAnalysisApiConfig.password;

        if (username == null ||
            username.isEmpty ||
            password == null ||
            password.isEmpty) {
          _log('Login', 'ERROR: Credentials not available for direct API call',
              isError: true);
          return Result.error(
              'Credentials not configured. Please use backend proxy (set backendBaseUrl) or provide credentials securely.');
        }

        // Note: Login is only needed for direct API calls
        // Backend proxy handles authentication automatically
      } else {
        // Backend proxy handles authentication, login endpoint not needed
        _log('Login', 'Backend proxy is enabled, login not required',
            isError: true);
        return Result.error(
            'Login not needed when using backend proxy. Backend handles authentication automatically.');
      }

      // This code path is only reached for direct API calls with valid credentials
      final username = FoodAnalysisApiConfig.username!;
      final password = FoodAnalysisApiConfig.password!;

      final url = FoodAnalysisApiConfig.getEndpointUrl(
          FoodAnalysisApiConfig.loginEndpoint);

      final request = LoginRequest(
        username: username,
        password: password,
      );

      _log('Login', 'Sending request to: $url');
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(FoodAnalysisApiConfig.requestTimeout);

      stopwatch.stop();
      _log('Login',
          'Response received: ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');

      if (response.statusCode == 200) {
        try {
          final jsonResponse =
              jsonDecode(response.body) as Map<String, dynamic>;
          final loginResponse = LoginResponse.fromJson(jsonResponse);

          // Validate response
          if (loginResponse.accessToken.isEmpty) {
            _log('Login', 'ERROR: Empty access token received', isError: true);
            return Result.error('Invalid response: empty access token');
          }

          // Store tokens
          _accessToken = loginResponse.accessToken;
          _refreshToken = loginResponse.refreshToken;
          _tokenExpiresAt = loginResponse.expiresIn;

          await _storeTokens();
          _log('Login', 'Authentication successful, tokens stored');

          return Result.success(loginResponse);
        } catch (e) {
          _log('Login', 'ERROR: Failed to parse response: $e', isError: true);
          return Result.error(
              'Failed to parse login response: ${e.toString()}');
        }
      } else {
        final errorMsg =
            _parseApiError(response.statusCode, response.body, 'Login');
        _log('Login', 'ERROR: $errorMsg', isError: true);
        return Result.error(errorMsg);
      }
    } on TimeoutException catch (e) {
      _log('Login', 'ERROR: Request timeout', isError: true);
      return Result.error('Login timeout: ${e.toString()}');
    } catch (e) {
      _log('Login', 'ERROR: Unexpected error: $e', isError: true);
      return Result.error('Login error: ${e.toString()}');
    }
  }

  // ========== Private Authentication Helpers ==========

  /// Ensures authentication is valid before making API calls
  ///
  /// Checks if token exists and is not expired.
  /// If expired or missing, automatically logs in.
  ///
  /// Returns [Result<bool>] indicating if authentication is valid.
  Future<Result<bool>> _ensureAuthenticated() async {
    // Check if token exists and is not expired
    if (_accessToken != null && _tokenExpiresAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now < _tokenExpiresAt! - 60000) {
        // Token is valid (with 1 minute buffer)
        _log('Auth', 'Token is valid');
        return Result.success(true);
      } else {
        _log('Auth', 'Token expired, refreshing...');
      }
    } else {
      _log('Auth', 'No token found, logging in...');
    }

    // Token expired or missing, try to login
    final loginResult = await login();
    if (loginResult.isError) {
      _log('Auth', 'ERROR: Authentication failed', isError: true);
      return Result.error(loginResult.error ?? 'Authentication failed');
    }

    _log('Auth', 'Authentication successful');
    return Result.success(true);
  }

  /// Gets authentication headers with Bearer token
  ///
  /// Returns headers map with Authorization and Content-Type.
  Map<String, String> _getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };
  }

  /// Stores tokens in SharedPreferences and Supabase for persistence
  ///
  /// Saves access token, refresh token, and expiration timestamp.
  /// Syncs to Supabase database if user is authenticated.
  Future<void> _storeTokens() async {
    // Store in SharedPreferences (local fallback)
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null) {
      await prefs.setString(
          FoodAnalysisApiConfig.accessTokenKey, _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString(
          FoodAnalysisApiConfig.refreshTokenKey, _refreshToken!);
    }
    if (_tokenExpiresAt != null) {
      await prefs.setInt(
          FoodAnalysisApiConfig.tokenExpiresAtKey, _tokenExpiresAt!);
    }

    // Sync to Supabase database if user is authenticated
    final userId = SupabaseConfig.userId;
    if (userId != null &&
        _accessToken != null &&
        _refreshToken != null &&
        _tokenExpiresAt != null) {
      try {
        await IntrestTokenService.saveTokens(
          userId: userId,
          accessToken: _accessToken!,
          refreshToken: _refreshToken!,
          expiresIn: _tokenExpiresAt!,
        );
        _log('StoreTokens', 'Tokens synced to Supabase database');
      } catch (e) {
        _log('StoreTokens', 'Warning: Failed to sync tokens to Supabase: $e',
            isError: true);
        // Continue - local storage still works
      }
    }
  }

  /// Loads tokens from Supabase database or SharedPreferences
  ///
  /// Restores authentication state from previous app session.
  /// Checks Supabase first (if user is authenticated), then falls back to SharedPreferences.
  Future<void> _loadTokens() async {
    // Try to load from Supabase first (if user is authenticated)
    final userId = SupabaseConfig.userId;
    if (userId != null) {
      try {
        final token = await IntrestTokenService.loadTokens(userId);
        if (token != null && token.isValid) {
          _accessToken = token.accessToken;
          _refreshToken = token.refreshToken;
          _tokenExpiresAt = IntrestApiToken.dateTimeToExpiresIn(token.expiresAt);
          _log('LoadTokens', 'Tokens loaded from Supabase database');
          return;
        } else if (token != null && token.isExpired) {
          _log('LoadTokens', 'Tokens in Supabase are expired, will re-authenticate');
        }
      } catch (e) {
        _log('LoadTokens', 'Warning: Failed to load tokens from Supabase: $e',
            isError: true);
        // Fall through to SharedPreferences
      }
    }

    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(FoodAnalysisApiConfig.accessTokenKey);
    _refreshToken = prefs.getString(FoodAnalysisApiConfig.refreshTokenKey);
    _tokenExpiresAt = prefs.getInt(FoodAnalysisApiConfig.tokenExpiresAtKey);

    if (_accessToken != null) {
      _log('LoadTokens', 'Tokens loaded from SharedPreferences');
    }
  }

  /// Checks if the current token is expired
  ///
  /// Uses expiration timestamp with 1-minute buffer for safety.
  bool _isTokenExpired() {
    if (_tokenExpiresAt == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= _tokenExpiresAt! - 60000; // 1 minute buffer
  }

  /// Refreshes authentication token
  ///
  /// Currently re-authenticates by calling login.
  /// Can be extended to use refresh token API if available.
  Future<Result<bool>> _refreshAuthToken() async {
    // If refresh token API exists, implement it here
    // For now, just re-login
    return await _ensureAuthenticated();
  }

  // ========== HTTP Request Helpers ==========

  /// Makes an authenticated API request with retry logic
  ///
  /// Handles:
  /// - Automatic authentication (only for direct API calls, not backend proxy)
  /// - Token refresh on 401 errors (only for direct API calls)
  /// - Retry logic for network errors
  /// - Timeout handling
  /// - Specific HTTP status code handling
  ///
  /// [endpoint] - API endpoint path
  /// [body] - Request body as JSON map
  /// [retryCount] - Current retry attempt (internal use)
  ///
  /// Returns [Result<Map<String, dynamic>>] with parsed JSON response or error.
  Future<Result<Map<String, dynamic>>> _makeRequest(
    String endpoint,
    Map<String, dynamic> body, {
    int retryCount = 0,
  }) async {
    final stopwatch = Stopwatch()..start();
    final endpointName = endpoint.split('/').last;
    final isBackendProxy = FoodAnalysisApiConfig.useBackendProxy;

    // Ensure authenticated (only for direct API calls, backend handles auth)
    if (!isBackendProxy) {
      final authResult = await _ensureAuthenticated();
      if (authResult.isError) {
        return Result.error(authResult.error ?? 'Authentication failed');
      }
    }

    // Declare variables outside try block for use in catch block
    final url = FoodAnalysisApiConfig.getEndpointUrl(endpoint);
    final headers = isBackendProxy
        ? {'Content-Type': 'application/json'}
        : _getAuthHeaders();

    try {
      // Explicit console logging for debugging
      print('🔍 [FoodAnalysisService] Making POST request:');
      print('   URL: $url');
      print('   Endpoint: $endpoint');
      print('   Backend Proxy: $isBackendProxy');
      print('   Backend Base URL: ${FoodAnalysisApiConfig.backendBaseUrl}');
      print('   Body: ${jsonEncode(body)}');

      _log(endpointName, 'Request: ${jsonEncode(body)}');
      _log(endpointName, 'Using backend proxy: $isBackendProxy');
      _log(endpointName, 'Full URL: $url');
      _log(endpointName, 'Original endpoint: $endpoint');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(FoodAnalysisApiConfig.requestTimeout);

      stopwatch.stop();
      _log(endpointName,
          'Response: ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');

      // Handle 401 Unauthorized - try to refresh token and retry once (only for direct API calls)
      if (response.statusCode == 401 && retryCount == 0 && !isBackendProxy) {
        _log(endpointName, 'Unauthorized, refreshing token...');
        final refreshResult = await _refreshAuthToken();
        if (refreshResult.isSuccess) {
          // Retry the request once
          _log(endpointName, 'Retrying request after token refresh...');
          return await _makeRequest(endpoint, body, retryCount: 1);
        } else {
          return Result.error('Authentication failed after token refresh');
        }
      }

      // Handle specific HTTP status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonResponse =
              jsonDecode(response.body) as Map<String, dynamic>;
          _log(endpointName, 'Success');
          return Result.success(jsonResponse);
        } catch (e) {
          _log(endpointName, 'ERROR: Failed to parse JSON response: $e',
              isError: true);
          return Result.error('Invalid JSON response: ${e.toString()}');
        }
      } else {
        final errorMsg =
            _parseApiError(response.statusCode, response.body, endpointName);
        _log(endpointName, 'ERROR: $errorMsg', isError: true);
        _log(endpointName, 'Response status: ${response.statusCode}',
            isError: true);
        _log(endpointName,
            'Response preview: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}',
            isError: true);
        return Result.error(errorMsg);
      }
    } on TimeoutException catch (e) {
      stopwatch.stop();
      _log(endpointName,
          'ERROR: Request timeout (${stopwatch.elapsedMilliseconds}ms)',
          isError: true);
      // Retry on timeout
      if (retryCount < FoodAnalysisApiConfig.maxRetries) {
        _log(endpointName,
            'Retrying after timeout (attempt ${retryCount + 1}/${FoodAnalysisApiConfig.maxRetries})...');
        await Future.delayed(FoodAnalysisApiConfig.retryDelay);
        return await _makeRequest(endpoint, body, retryCount: retryCount + 1);
      }
      return Result.error('Request timeout: ${e.toString()}');
    } catch (e) {
      stopwatch.stop();
      final errorString = e.toString().toLowerCase();

      // Enhanced error logging with full request details
      _log(endpointName,
          'ERROR: Network error after ${stopwatch.elapsedMilliseconds}ms',
          isError: true);
      _log(endpointName, 'ERROR Type: ${e.runtimeType}', isError: true);
      _log(endpointName, 'ERROR Message: $e', isError: true);
      _log(endpointName, 'ERROR URL: $url', isError: true);
      _log(endpointName, 'ERROR Headers: ${jsonEncode(headers)}',
          isError: true);
      _log(endpointName, 'ERROR Body: ${jsonEncode(body)}', isError: true);
      _log(endpointName, 'ERROR Retry Count: $retryCount', isError: true);
      _log(endpointName, 'ERROR Using Backend Proxy: $isBackendProxy',
          isError: true);

      // Check for CORS-related errors
      if (errorString.contains('cors') ||
          errorString.contains('blocked') ||
          errorString.contains('access-control') ||
          errorString.contains('network error') ||
          errorString.contains('failed to fetch') ||
          errorString.contains('clientexception')) {
        final detailedError = '''
CORS or Network Error detected!

Request Details:
- URL: $url
- Endpoint: $endpoint
- Using Backend Proxy: $isBackendProxy
- Retry Attempt: ${retryCount + 1}/${FoodAnalysisApiConfig.maxRetries + 1}

Troubleshooting Steps:
1. Verify backend server is running:
   - Check: http://localhost:3000/api/docs
   - Expected: Swagger documentation should load
   
2. Test backend connectivity:
   - Open browser console (F12)
   - Try: fetch('http://localhost:3000/api/food-analysis/full-pipeline', {method: 'POST', headers: {'Content-Type': 'application/json'}, body: '{"dishName":"test"}'})
   
3. Backend setup verification:
   - Install dependencies: cd backend && npm install
   - Check .env file exists with:
     FOOD_ANALYSIS_API_URL=https://api.intrest.ca
     FOOD_ANALYSIS_USERNAME=2220001790@iau.edu.sa
     FOOD_ANALYSIS_PASSWORD=1qaz!QAZ
   - Start backend: cd backend && npm run start:dev
   - Look for: "✅ Server started successfully and listening on port 3000"
   
4. Check browser console for detailed error messages

Original Error: $e
''';
        _log(endpointName, detailedError, isError: true);
        return Result.error(detailedError);
      }

      // Retry on network errors
      if (retryCount < FoodAnalysisApiConfig.maxRetries) {
        _log(endpointName,
            'Retrying after error (attempt ${retryCount + 1}/${FoodAnalysisApiConfig.maxRetries})...');
        await Future.delayed(FoodAnalysisApiConfig.retryDelay);
        return await _makeRequest(endpoint, body, retryCount: retryCount + 1);
      }

      // Final error with full context
      final finalError =
          'Network error after ${retryCount + 1} attempts: ${e.toString()}\n'
          'URL: $url\n'
          'Endpoint: $endpoint\n'
          'Using Backend Proxy: $isBackendProxy';
      _log(endpointName, finalError, isError: true);
      return Result.error(finalError);
    }
  }

  // ========== Input Validation Methods ==========

  /// Validates dish name input
  /// Returns null if valid, error message if invalid
  String? _validateDishName(String dishName) {
    if (dishName.trim().isEmpty) {
      return 'Dish name cannot be empty';
    }
    if (dishName.trim().length < 2) {
      return 'Dish name must be at least 2 characters';
    }
    if (dishName.trim().length > 200) {
      return 'Dish name must be less than 200 characters';
    }
    return null;
  }

  /// Validates ingredient list input
  /// Returns null if valid, error message if invalid
  String? _validateIngredientList(List<String> ingredients) {
    if (ingredients.isEmpty) {
      return 'Ingredient list cannot be empty';
    }
    if (ingredients.length > 100) {
      return 'Ingredient list cannot exceed 100 items';
    }
    for (var ingredient in ingredients) {
      if (ingredient.trim().isEmpty) {
        return 'Ingredient names cannot be empty';
      }
    }
    return null;
  }

  /// Validates quantities map
  /// Returns null if valid, error message if invalid
  String? _validateQuantities(Map<String, double>? quantities) {
    if (quantities == null) return null;
    for (var entry in quantities.entries) {
      if (entry.value <= 0) {
        return 'Quantity must be greater than 0 for ingredient: ${entry.key}';
      }
      if (entry.value > 100000) {
        return 'Quantity too large for ingredient: ${entry.key}';
      }
    }
    return null;
  }

  /// Validates nutrient list
  /// Returns null if valid, error message if invalid
  String? _validateNutrientList(List<Nutrient> nutrients) {
    if (nutrients.isEmpty) {
      return 'Nutrient list cannot be empty';
    }
    if (nutrients.length > 200) {
      return 'Nutrient list cannot exceed 200 items';
    }
    return null;
  }

  // ========== Error Handling Helpers ==========

  /// Parses API error response and returns user-friendly error message
  String _parseApiError(int statusCode, String responseBody, String endpoint) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>?;
      if (json != null && json.containsKey('message')) {
        return json['message'] as String;
      }
      if (json != null && json.containsKey('error')) {
        return json['error'] as String;
      }
    } catch (_) {
      // If parsing fails, use status code
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input parameters.';
      case 401:
        return 'Authentication failed. Please try again.';
      case 403:
        return 'Access forbidden. You may not have permission for this operation.';
      case 404:
        return 'Endpoint not found. The requested resource does not exist.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service unavailable. The server is temporarily down.';
      default:
        return 'API error (${statusCode}): ${responseBody.length > 100 ? responseBody.substring(0, 100) + '...' : responseBody}';
    }
  }

  // ========== Logging Helpers ==========

  /// Logs debug messages (only in debug mode)
  void _log(String context, String message, {bool isError = false}) {
    if (kDebugMode) {
      final prefix =
          isError ? '❌ [FoodAnalysisService]' : '✅ [FoodAnalysisService]';
      debugPrint('$prefix [$context] $message');
    }
  }

  // ========== Safe Response Parsing Helpers ==========

  /// Safely parses IngredientExtractionResponse with null safety
  IngredientExtractionResponse _parseIngredientExtractionResponse(
      Map<String, dynamic> json) {
    try {
      final ingredients = (json['ingredients'] as List<dynamic>?)
              ?.map((i) => _parseIngredient(i as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];

      final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.0;

      return IngredientExtractionResponse(
        ingredients: ingredients,
        confidence: confidence,
      );
    } catch (e) {
      throw FormatException('Failed to parse IngredientExtractionResponse: $e');
    }
  }

  /// Safely parses Ingredient with null safety
  Ingredient _parseIngredient(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] != null
          ? (json['quantity'] as num).toDouble()
          : null,
      unit: json['unit'] as String?,
      category: json['category'] as String?,
    );
  }

  /// Safely parses AllergenAnalysisResponse with null safety
  AllergenAnalysisResponse _parseAllergenAnalysisResponse(
      Map<String, dynamic> json) {
    try {
      final allergens = (json['allergens'] as List<dynamic>?)
              ?.map((a) => _parseAllergen(a as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];

      final riskLevel = (json['riskLevel'] as num?)?.toDouble() ?? 0.0;
      final warning = json['warning'] as String?;

      return AllergenAnalysisResponse(
        allergens: allergens,
        riskLevel: riskLevel,
        warning: warning,
      );
    } catch (e) {
      throw FormatException('Failed to parse AllergenAnalysisResponse: $e');
    }
  }

  /// Safely parses Allergen with null safety
  Allergen _parseAllergen(Map<String, dynamic> json) {
    return Allergen(
      name: json['name'] as String? ?? '',
      severity: json['severity'] as String? ?? 'low',
      description: json['description'] as String?,
    );
  }

  /// Safely parses DietCompatibilityResponse with null safety
  DietCompatibilityResponse _parseDietCompatibilityResponse(
      Map<String, dynamic> json) {
    try {
      final compatibilities = (json['compatibilities'] as List<dynamic>?)
              ?.map((c) =>
                  _parseDietCompatibility(c as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];

      final overallScore = (json['overallScore'] as num?)?.toDouble() ?? 0.0;

      return DietCompatibilityResponse(
        compatibilities: compatibilities,
        overallScore: overallScore,
      );
    } catch (e) {
      throw FormatException('Failed to parse DietCompatibilityResponse: $e');
    }
  }

  /// Safely parses DietCompatibility with null safety
  DietCompatibility _parseDietCompatibility(Map<String, dynamic> json) {
    return DietCompatibility(
      dietType: json['dietType'] as String? ?? '',
      isCompatible: json['isCompatible'] as bool? ?? false,
      compatibilityScore:
          (json['compatibilityScore'] as num?)?.toDouble() ?? 0.0,
      incompatibleIngredients: json['incompatibleIngredients'] != null
          ? List<String>.from(json['incompatibleIngredients'] as List)
          : null,
      reason: json['reason'] as String?,
    );
  }

  /// Safely parses NutrientCalculationResponse with null safety
  NutrientCalculationResponse _parseNutrientCalculationResponse(
      Map<String, dynamic> json) {
    try {
      final nutrients = (json['nutrients'] as List<dynamic>?)
              ?.map((n) => _parseNutrient(n as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];

      final totalCalories = (json['totalCalories'] as num?)?.toDouble() ?? 0.0;
      final macronutrients = json['macronutrients'] != null
          ? Map<String, double>.from(json['macronutrients'] as Map)
          : <String, double>{};

      return NutrientCalculationResponse(
        nutrients: nutrients,
        totalCalories: totalCalories,
        macronutrients: macronutrients,
      );
    } catch (e) {
      throw FormatException('Failed to parse NutrientCalculationResponse: $e');
    }
  }

  /// Safely parses Nutrient with null safety
  Nutrient _parseNutrient(Map<String, dynamic> json) {
    return Nutrient(
      name: json['name'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'g',
      dailyValuePercentage: json['dailyValuePercentage'] != null
          ? (json['dailyValuePercentage'] as num).toDouble()
          : null,
    );
  }

  /// Safely parses GenerateNutrientLabelsResponse with null safety
  GenerateNutrientLabelsResponse _parseGenerateNutrientLabelsResponse(
      Map<String, dynamic> json) {
    try {
      final labels = (json['labels'] as List<dynamic>?)
              ?.map(
                  (l) => _parseNutrientLabel(l as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];

      final healthScore = (json['healthScore'] as num?)?.toDouble() ?? 0.0;

      return GenerateNutrientLabelsResponse(
        labels: labels,
        healthScore: healthScore,
      );
    } catch (e) {
      throw FormatException(
          'Failed to parse GenerateNutrientLabelsResponse: $e');
    }
  }

  /// Safely parses NutrientLabel with null safety
  NutrientLabel _parseNutrientLabel(Map<String, dynamic> json) {
    return NutrientLabel(
      label: json['label'] as String? ?? '',
      category: json['category'] as String? ?? 'medium',
      description: json['description'] as String?,
    );
  }

  // ========== API Endpoint Methods ==========
  // All methods automatically handle authentication and return Result<T>

  /// 1. Extract ingredients from dish name
  ///
  /// Analyzes a dish name and extracts the list of ingredients.
  ///
  /// [dishName] - Name of the dish to analyze (e.g., "Grilled Chicken Salad")
  ///
  /// Returns [Result<IngredientExtractionResponse>] with ingredients list and confidence score.
  Future<Result<IngredientExtractionResponse>> extractIngredients(
      String dishName) async {
    // Input validation
    final validationError = _validateDishName(dishName);
    if (validationError != null) {
      _log('ExtractIngredients', 'Validation failed: $validationError',
          isError: true);
      return Result.error(validationError);
    }

    final request = IngredientExtractionRequest(dishName: dishName.trim());
    final result = await _makeRequest(
      FoodAnalysisApiConfig.extractIngredientsEndpoint,
      request.toJson(),
    );

    if (result.isError) {
      return Result.error(result.error ?? 'Failed to extract ingredients');
    }

    try {
      final response = _parseIngredientExtractionResponse(result.data!);
      return Result.success(response);
    } catch (e) {
      _log('ExtractIngredients', 'Parse error: $e', isError: true);
      return Result.error('Failed to parse response: ${e.toString()}');
    }
  }

  /// 2. Analyze allergens by dish name
  ///
  /// Identifies potential allergens in a dish from its name.
  ///
  /// [dishName] - Name of the dish to analyze
  ///
  /// Returns [Result<AllergenAnalysisResponse>] with allergens list and risk level.
  Future<Result<AllergenAnalysisResponse>> analyzeAllergensByDish(
      String dishName) async {
    // Input validation
    final validationError = _validateDishName(dishName);
    if (validationError != null) {
      _log('AnalyzeAllergensByDish', 'Validation failed: $validationError',
          isError: true);
      return Result.error(validationError);
    }

    final request = AllergenAnalysisByDishRequest(dishName: dishName.trim());
    final result = await _makeRequest(
      FoodAnalysisApiConfig.analyzeAllergensByDishEndpoint,
      request.toJson(),
    );

    if (result.isError) {
      return Result.error(result.error ?? 'Failed to analyze allergens');
    }

    try {
      final response = _parseAllergenAnalysisResponse(result.data!);
      return Result.success(response);
    } catch (e) {
      _log('AnalyzeAllergensByDish', 'Parse error: $e', isError: true);
      return Result.error('Failed to parse response: ${e.toString()}');
    }
  }

  /// 3. Analyze allergens by ingredient list
  ///
  /// Identifies potential allergens from a list of ingredients.
  ///
  /// [ingredients] - List of ingredient names (e.g., ["chicken", "butter", "flour"])
  ///
  /// Returns [Result<AllergenAnalysisResponse>] with allergens list and risk level.
  Future<Result<AllergenAnalysisResponse>> analyzeAllergensByIngredients(
      List<String> ingredients) async {
    // Input validation
    final validationError = _validateIngredientList(ingredients);
    if (validationError != null) {
      _log('AnalyzeAllergensByIngredients',
          'Validation failed: $validationError',
          isError: true);
      return Result.error(validationError);
    }

    // Trim ingredient names
    final trimmedIngredients = ingredients.map((i) => i.trim()).toList();
    final request =
        AllergenAnalysisByIngredientsRequest(ingredients: trimmedIngredients);
    final result = await _makeRequest(
      FoodAnalysisApiConfig.analyzeAllergensByIngredientsEndpoint,
      request.toJson(),
    );

    if (result.isError) {
      return Result.error(result.error ?? 'Failed to analyze allergens');
    }

    try {
      final response = _parseAllergenAnalysisResponse(result.data!);
      return Result.success(response);
    } catch (e) {
      _log('AnalyzeAllergensByIngredients', 'Parse error: $e', isError: true);
      return Result.error('Failed to parse response: ${e.toString()}');
    }
  }

  /// 4. Extract ingredients and analyze allergens (combined)
  ///
  /// Performs both ingredient extraction and allergen analysis in a single call.
  /// More efficient than calling the methods separately.
  ///
  /// [dishName] - Name of the dish to analyze
  ///
  /// Returns [Result<ExtractIngredientsAndAnalyzeAllergensResponse>] with both ingredients and allergens.
  Future<Result<ExtractIngredientsAndAnalyzeAllergensResponse>>
      extractIngredientsAndAnalyzeAllergens(String dishName) async {
    // Input validation
    final validationError = _validateDishName(dishName);
    if (validationError != null) {
      _log('ExtractIngredientsAndAnalyzeAllergens',
          'Validation failed: $validationError',
          isError: true);
      return Result.error(validationError);
    }

    final request = IngredientExtractionRequest(dishName: dishName.trim());
    final result = await _makeRequest(
      FoodAnalysisApiConfig.extractIngredientsAndAnalyzeAllergensEndpoint,
      request.toJson(),
    );

    if (result.isError) {
      return Result.error(result.error ??
          'Failed to extract ingredients and analyze allergens');
    }

    try {
      final json = result.data!;
      final ingredients = (json['ingredients'] as List<dynamic>?)
              ?.map((i) => _parseIngredient(i as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];
      final allergens = (json['allergens'] as List<dynamic>?)
              ?.map((a) => _parseAllergen(a as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];
      final riskLevel = (json['riskLevel'] as num?)?.toDouble() ?? 0.0;
      final warning = json['warning'] as String?;

      final response = ExtractIngredientsAndAnalyzeAllergensResponse(
        ingredients: ingredients,
        allergens: allergens,
        riskLevel: riskLevel,
        warning: warning,
      );
      return Result.success(response);
    } catch (e) {
      _log('ExtractIngredientsAndAnalyzeAllergens', 'Parse error: $e',
          isError: true);
      return Result.error('Failed to parse response: ${e.toString()}');
    }
  }

  /// 5. Analyze diet compatibility by dish name
  ///
  /// Checks if a dish is compatible with specific dietary requirements.
  ///
  /// [dishName] - Name of the dish to analyze
  /// [dietTypes] - Optional list of specific diets to check (e.g., ["vegan", "keto", "halal"])
  ///              If null, checks all common diets
  ///
  /// Returns [Result<DietCompatibilityResponse>] with compatibility scores for each diet.
  Future<Result<DietCompatibilityResponse>> analyzeDietCompatibilityByDish(
    String dishName, {
    List<String>? dietTypes,
  }) async {
    // Input validation
    final validationError = _validateDishName(dishName);
    if (validationError != null) {
      _log('AnalyzeDietCompatibilityByDish',
          'Validation failed: $validationError',
          isError: true);
      return Result.error(validationError);
    }

    final request = DietCompatibilityByDishRequest(
        dishName: dishName.trim(), dietTypes: dietTypes);
    final result = await _makeRequest(
      FoodAnalysisApiConfig.analyzeDietCompatibilityByDishEndpoint,
      request.toJson(),
    );

    if (result.isError) {
      return Result.error(
          result.error ?? 'Failed to analyze diet compatibility');
    }

    try {
      final response = _parseDietCompatibilityResponse(result.data!);
      return Result.success(response);
    } catch (e) {
      _log('AnalyzeDietCompatibilityByDish', 'Parse error: $e', isError: true);
      return Result.error('Failed to parse response: ${e.toString()}');
    }
  }

  /// 6. Analyze diet compatibility by ingredient list
  ///
  /// Checks if a list of ingredients is compatible with specific dietary requirements.
  ///
  /// [ingredients] - List of ingredient names
  /// [dietTypes] - Optional list of specific diets to check
  ///
  /// Returns [Result<DietCompatibilityResponse>] with compatibility scores.
  Future<Result<DietCompatibilityResponse>>
      analyzeDietCompatibilityByIngredients(
    List<String> ingredients, {
    List<String>? dietTypes,
  }) async {
    // Input validation
    final validationError = _validateIngredientList(ingredients);
    if (validationError != null) {
      _log('AnalyzeDietCompatibilityByIngredients',
          'Validation failed: $validationError',
          isError: true);
      return Result.error(validationError);
    }

    // Trim ingredient names
    final trimmedIngredients = ingredients.map((i) => i.trim()).toList();
    final request = DietCompatibilityByIngredientsRequest(
        ingredients: trimmedIngredients, dietTypes: dietTypes);
    final result = await _makeRequest(
      FoodAnalysisApiConfig.analyzeDietCompatibilityByIngredientsEndpoint,
      request.toJson(),
    );

    if (result.isError) {
      return Result.error(
          result.error ?? 'Failed to analyze diet compatibility');
    }

    try {
      final response = _parseDietCompatibilityResponse(result.data!);
      return Result.success(response);
    } catch (e) {
      _log('AnalyzeDietCompatibilityByIngredients', 'Parse error: $e',
          isError: true);
      return Result.error('Failed to parse response: ${e.toString()}');
    }
  }

  /// 7. Extract ingredients and analyze diet compatibility (combined)
  ///
  /// Performs both ingredient extraction and diet analysis in a single call.
  ///
  /// [dishName] - Name of the dish to analyze
  /// [dietTypes] - Optional list of specific diets to check
  ///
  /// Returns [Result<ExtractIngredientsAndAnalyzeDietResponse>] with ingredients and compatibility data.
  Future<Result<ExtractIngredientsAndAnalyzeDietResponse>>
      extractIngredientsAndAnalyzeDiet(
    String dishName, {
    List<String>? dietTypes,
  }) async {
    // Input validation
    final validationError = _validateDishName(dishName);
    if (validationError != null) {
      _log('ExtractIngredientsAndAnalyzeDiet',
          'Validation failed: $validationError',
          isError: true);
      return Result.error(validationError);
    }

    final request = DietCompatibilityByDishRequest(
        dishName: dishName.trim(), dietTypes: dietTypes);
    final result = await _makeRequest(
      FoodAnalysisApiConfig.extractIngredientsAndAnalyzeDietEndpoint,
      request.toJson(),
    );

    if (result.isError) {
      return Result.error(
          result.error ?? 'Failed to extract ingredients and analyze diet');
    }

    try {
      final json = result.data!;
      final ingredients = (json['ingredients'] as List<dynamic>?)
              ?.map((i) => _parseIngredient(i as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];
      final compatibilities = (json['compatibilities'] as List<dynamic>?)
              ?.map((c) =>
                  _parseDietCompatibility(c as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];
      final overallScore = (json['overallScore'] as num?)?.toDouble() ?? 0.0;

      final response = ExtractIngredientsAndAnalyzeDietResponse(
        ingredients: ingredients,
        compatibilities: compatibilities,
        overallScore: overallScore,
      );
      return Result.success(response);
    } catch (e) {
      _log('ExtractIngredientsAndAnalyzeDiet', 'Parse error: $e',
          isError: true);
      return Result.error('Failed to parse response: ${e.toString()}');
    }
  }

  /// 8. Calculate nutrients from ingredients
  ///
  /// Calculates nutritional content (calories, macros, vitamins, etc.) from a list of ingredients.
  ///
  /// [ingredients] - List of ingredient names
  /// [quantities] - Optional map of ingredient quantities (e.g., {"chicken": 200.0, "rice": 150.0})
  ///               If not provided, uses default serving sizes
  ///
  /// Returns [Result<NutrientCalculationResponse>] with detailed nutritional breakdown.
  Future<Result<NutrientCalculationResponse>> calculateNutrients(
    List<String> ingredients, {
    Map<String, double>? quantities,
  }) async {
    // Input validation
    final ingredientError = _validateIngredientList(ingredients);
    if (ingredientError != null) {
      _log('CalculateNutrients', 'Validation failed: $ingredientError',
          isError: true);
      return Result.error(ingredientError);
    }

    final quantityError = _validateQuantities(quantities);
    if (quantityError != null) {
      _log('CalculateNutrients', 'Validation failed: $quantityError',
          isError: true);
      return Result.error(quantityError);
    }

    // Trim ingredient names
    final trimmedIngredients = ingredients.map((i) => i.trim()).toList();
    final request = NutrientCalculationRequest(
        ingredients: trimmedIngredients, quantities: quantities);
    final result = await _makeRequest(
      FoodAnalysisApiConfig.calculateNutrientsEndpoint,
      request.toJson(),
    );

    if (result.isError) {
      return Result.error(result.error ?? 'Failed to calculate nutrients');
    }

    try {
      final response = _parseNutrientCalculationResponse(result.data!);
      return Result.success(response);
    } catch (e) {
      _log('CalculateNutrients', 'Parse error: $e', isError: true);
      return Result.error('Failed to parse response: ${e.toString()}');
    }
  }

  /// 9. Generate nutrient labels
  ///
  /// Generates health-related labels (e.g., "High Protein", "Low Sodium") based on nutrient data.
  ///
  /// [nutrients] - List of [Nutrient] objects with nutritional information
  ///
  /// Returns [Result<GenerateNutrientLabelsResponse>] with labels and overall health score.
  Future<Result<GenerateNutrientLabelsResponse>> generateNutrientLabels(
      List<Nutrient> nutrients) async {
    // Input validation
    final validationError = _validateNutrientList(nutrients);
    if (validationError != null) {
      _log('GenerateNutrientLabels', 'Validation failed: $validationError',
          isError: true);
      return Result.error(validationError);
    }

    final request = GenerateNutrientLabelsRequest(nutrients: nutrients);
    final result = await _makeRequest(
      FoodAnalysisApiConfig.generateNutrientLabelsEndpoint,
      request.toJson(),
    );

    if (result.isError) {
      return Result.error(result.error ?? 'Failed to generate nutrient labels');
    }

    try {
      final response = _parseGenerateNutrientLabelsResponse(result.data!);
      return Result.success(response);
    } catch (e) {
      _log('GenerateNutrientLabels', 'Parse error: $e', isError: true);
      return Result.error('Failed to parse response: ${e.toString()}');
    }
  }

  /// 10. Extract ingredients and calculate nutrients (combined)
  ///
  /// Performs both ingredient extraction and nutrient calculation in a single call.
  ///
  /// [dishName] - Name of the dish to analyze
  /// [quantities] - Optional map of ingredient quantities
  ///
  /// Returns [Result<ExtractIngredientsAndCalculateNutrientsResponse>] with ingredients and nutrients.
  Future<Result<ExtractIngredientsAndCalculateNutrientsResponse>>
      extractIngredientsAndCalculateNutrients(
    String dishName, {
    Map<String, double>? quantities,
  }) async {
    // Input validation
    final dishError = _validateDishName(dishName);
    if (dishError != null) {
      _log('ExtractIngredientsAndCalculateNutrients',
          'Validation failed: $dishError',
          isError: true);
      return Result.error(dishError);
    }

    final quantityError = _validateQuantities(quantities);
    if (quantityError != null) {
      _log('ExtractIngredientsAndCalculateNutrients',
          'Validation failed: $quantityError',
          isError: true);
      return Result.error(quantityError);
    }

    final request = IngredientExtractionRequest(dishName: dishName.trim());
    final requestBody = request.toJson();
    if (quantities != null) {
      requestBody['quantities'] = quantities;
    }

    final result = await _makeRequest(
      FoodAnalysisApiConfig.extractIngredientsAndCalculateNutrientsEndpoint,
      requestBody,
    );

    if (result.isError) {
      return Result.error(result.error ??
          'Failed to extract ingredients and calculate nutrients');
    }

    try {
      final json = result.data!;
      final ingredients = (json['ingredients'] as List<dynamic>?)
              ?.map((i) => _parseIngredient(i as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];
      final nutrients = (json['nutrients'] as List<dynamic>?)
              ?.map((n) => _parseNutrient(n as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];
      final totalCalories = (json['totalCalories'] as num?)?.toDouble() ?? 0.0;
      final macronutrients = json['macronutrients'] != null
          ? Map<String, double>.from(json['macronutrients'] as Map)
          : <String, double>{};

      final response = ExtractIngredientsAndCalculateNutrientsResponse(
        ingredients: ingredients,
        nutrients: nutrients,
        totalCalories: totalCalories,
        macronutrients: macronutrients,
      );
      return Result.success(response);
    } catch (e) {
      _log('ExtractIngredientsAndCalculateNutrients', 'Parse error: $e',
          isError: true);
      return Result.error('Failed to parse response: ${e.toString()}');
    }
  }

  /// 11. Full pipeline analysis (all in one)
  ///
  /// Performs complete analysis: ingredient extraction, allergen detection,
  /// diet compatibility, nutrient calculation, and label generation.
  ///
  /// This is the most comprehensive endpoint and provides all analysis data in one call.
  ///
  /// [dishName] - Name of the dish to analyze
  /// [dietTypes] - Optional list of specific diets to check
  /// [quantities] - Optional map of ingredient quantities
  ///
  /// Returns [Result<FullPipelineResponse>] with complete analysis data.
  Future<Result<FullPipelineResponse>> fullPipelineAnalysis(
    String dishName, {
    List<String>? dietTypes,
    Map<String, double>? quantities,
  }) async {
    // Input validation
    final dishError = _validateDishName(dishName);
    if (dishError != null) {
      _log('FullPipelineAnalysis', 'Validation failed: $dishError',
          isError: true);
      return Result.error(dishError);
    }

    final quantityError = _validateQuantities(quantities);
    if (quantityError != null) {
      _log('FullPipelineAnalysis', 'Validation failed: $quantityError',
          isError: true);
      return Result.error(quantityError);
    }

    final request = FullPipelineRequest(
        dishName: dishName.trim(),
        dietTypes: dietTypes,
        quantities: quantities);
    final result = await _makeRequest(
      FoodAnalysisApiConfig.fullPipelineEndpoint,
      request.toJson(),
    );

    if (result.isError) {
      return Result.error(
          result.error ?? 'Failed to perform full pipeline analysis');
    }

    try {
      final json = result.data!;
      final ingredients = (json['ingredients'] as List<dynamic>?)
              ?.map((i) => _parseIngredient(i as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];
      final allergens = (json['allergens'] as List<dynamic>?)
              ?.map((a) => _parseAllergen(a as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];
      final allergenRiskLevel =
          (json['allergenRiskLevel'] as num?)?.toDouble() ?? 0.0;
      final dietCompatibilities =
          (json['dietCompatibilities'] as List<dynamic>?)
                  ?.map((c) =>
                      _parseDietCompatibility(c as Map<String, dynamic>? ?? {}))
                  .toList() ??
              [];
      final dietOverallScore =
          (json['dietOverallScore'] as num?)?.toDouble() ?? 0.0;
      final nutrients = (json['nutrients'] as List<dynamic>?)
              ?.map((n) => _parseNutrient(n as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];
      final totalCalories = (json['totalCalories'] as num?)?.toDouble() ?? 0.0;
      final macronutrients = json['macronutrients'] != null
          ? Map<String, double>.from(json['macronutrients'] as Map)
          : <String, double>{};
      final labels = (json['labels'] as List<dynamic>?)
              ?.map(
                  (l) => _parseNutrientLabel(l as Map<String, dynamic>? ?? {}))
              .toList() ??
          [];
      final healthScore = (json['healthScore'] as num?)?.toDouble() ?? 0.0;

      final response = FullPipelineResponse(
        ingredients: ingredients,
        allergens: allergens,
        allergenRiskLevel: allergenRiskLevel,
        dietCompatibilities: dietCompatibilities,
        dietOverallScore: dietOverallScore,
        nutrients: nutrients,
        totalCalories: totalCalories,
        macronutrients: macronutrients,
        labels: labels,
        healthScore: healthScore,
      );
      return Result.success(response);
    } catch (e) {
      _log('FullPipelineAnalysis', 'Parse error: $e', isError: true);
      return Result.error('Failed to parse response: ${e.toString()}');
    }
  }

  // ========== Utility Methods ==========

  /// Clears stored tokens (logout)
  ///
  /// Removes all authentication tokens from memory, SharedPreferences, and Supabase.
  /// Use this when user explicitly logs out or when switching accounts.
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiresAt = null;

    // Clear from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(FoodAnalysisApiConfig.accessTokenKey);
    await prefs.remove(FoodAnalysisApiConfig.refreshTokenKey);
    await prefs.remove(FoodAnalysisApiConfig.tokenExpiresAtKey);

    // Clear from Supabase database if user is authenticated
    final userId = SupabaseConfig.userId;
    if (userId != null) {
      try {
        await IntrestTokenService.clearTokens(userId);
        _log('ClearTokens', 'Tokens cleared from Supabase database');
      } catch (e) {
        _log('ClearTokens', 'Warning: Failed to clear tokens from Supabase: $e',
            isError: true);
        // Continue - local tokens are cleared
      }
    }
  }
}
