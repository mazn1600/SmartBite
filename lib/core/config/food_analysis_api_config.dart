import 'package:flutter/foundation.dart' show kIsWeb;

/// Food Analysis API Configuration
///
/// Centralized configuration for the Food Analysis API integration.
/// Contains API credentials, endpoints, and configuration constants.
///
/// **Note:** Credentials are currently hardcoded. For production,
/// consider moving to environment variables or secure storage.
class FoodAnalysisApiConfig {
  // ========== API Base Configuration ==========

  /// External API base URL (direct to Food Analysis API)
  static const String baseUrl = 'https://api.intrest.ca';

  /// Backend proxy base URL (NestJS backend)
  /// Set to null or empty to disable backend proxy (use direct API calls)
  /// For production, always use backend proxy for better security
  static const String? backendBaseUrl = 'http://localhost:3000';

  /// Whether to use backend proxy
  /// Web apps always use backend proxy due to CORS restrictions
  /// Mobile apps also use backend proxy if backendBaseUrl is configured (recommended for security)
  static bool get useBackendProxy {
    if (kIsWeb) {
      return true; // Web always uses proxy due to CORS
    }
    // Mobile: use proxy if configured, otherwise use direct API
    return backendBaseUrl != null && backendBaseUrl!.isNotEmpty;
  }

  // ========== Authentication Credentials ==========
  // SECURITY NOTE: Credentials are NOT stored in source code.
  // For production, always use backend proxy (set backendBaseUrl).
  // If direct API calls are needed for development/testing, credentials must be provided
  // at runtime via environment variables or secure configuration.

  /// API username for authentication (only for direct API calls when backend proxy is disabled)
  /// Must be set at runtime from secure configuration - never hardcode in source
  static String? get username => null; // Set from secure config if needed

  /// API password for authentication (only for direct API calls when backend proxy is disabled)
  /// Must be set at runtime from secure configuration - never hardcode in source
  static String? get password => null; // Set from secure config if needed

  // ========== API Endpoints ==========
  /// Login endpoint for authentication
  static const String loginEndpoint = '/api/login';
  static const String extractIngredientsEndpoint = '/api/extract-ingredients';
  static const String backendBaseUrlForTest = 'http://localhost:3001';
  static const String analyzeAllergensByDishEndpoint =
      '/api/analyze-allergens/dish';
  static const String analyzeAllergensByIngredientsEndpoint =
      '/api/analyze-allergens/ingredients';
  static const String extractIngredientsAndAnalyzeAllergensEndpoint =
      '/api/extract-ingredients-analyze-allergens';
  static const String analyzeDietCompatibilityByDishEndpoint =
      '/api/analyze-diet-compatibility/dish';
  static const String analyzeDietCompatibilityByIngredientsEndpoint =
      '/api/analyze-diet-compatibility/ingredients';
  static const String extractIngredientsAndAnalyzeDietEndpoint =
      '/api/extract-ingredients-analyze-diet';
  static const String calculateNutrientsEndpoint = '/api/calculate-nutrients';
  static const String generateNutrientLabelsEndpoint =
      '/api/generate-nutrient-labels';
  static const String extractIngredientsAndCalculateNutrientsEndpoint =
      '/api/extract-ingredients-calculate-nutrients';
  static const String fullPipelineEndpoint = '/api/full-pipeline';

  /// Storage keys for token persistence
  static const String accessTokenKey = 'food_analysis_access_token';
  static const String refreshTokenKey = 'food_analysis_refresh_token';
  static const String tokenExpiresAtKey = 'food_analysis_token_expires_at';

  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  /// Get full URL for an endpoint
  /// Routes through backend proxy when configured to avoid CORS issues and improve security
  static String getEndpointUrl(String endpoint) {
    if (useBackendProxy && backendBaseUrl != null) {
      // Route through backend proxy
      // Backend endpoints are at /api/food-analysis/{endpoint-name}
      // Map external API endpoints to backend proxy endpoints
      final proxyEndpoint = _mapToBackendProxyEndpoint(endpoint);
      return '$backendBaseUrl$proxyEndpoint';
    } else {
      // Direct API call (only when backend proxy is disabled)
      // WARNING: This requires credentials and should only be used for development/testing
      return '$baseUrl$endpoint';
    }
  }

  /// Maps external API endpoint to backend proxy endpoint
  /// Example: /api/login -> /api/food-analysis/login (not needed, no login endpoint in proxy)
  /// Example: /api/extract-ingredients -> /api/food-analysis/extract-ingredients
  /// Example: /api/full-pipeline -> /api/food-analysis/full-pipeline
  static String _mapToBackendProxyEndpoint(String endpoint) {
    // Remove leading /api if present
    String path = endpoint.startsWith('/api/')
        ? endpoint
            .substring(5) // Remove '/api/' (5 chars including trailing slash)
        : endpoint.startsWith('/')
            ? endpoint.substring(1) // Remove leading '/'
            : endpoint;

    // Map to backend proxy path
    // The backend controller uses 'food-analysis' path
    // NestJS global prefix adds /api automatically
    // So the full path will be: /api/food-analysis/{path}
    return '/api/food-analysis/$path';
  }
}
