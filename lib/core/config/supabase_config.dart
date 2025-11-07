import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and client setup
///
/// Configuration is loaded from dart-define variables:
/// - SUPABASE_URL: Your Supabase project URL
/// - SUPABASE_ANON_KEY: Your Supabase anonymous key
///
/// Example usage:
/// ```
/// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxx
/// ```
class SupabaseConfig {
  // Load from dart-define with fallback for development
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pnihaeljbyjiexnfolir.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBuaWhhZWxqYnlqaWV4bmZvbGlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEzNjgzMzgsImV4cCI6MjA3Njk0NDMzOH0.XANTGUKmfeIaRb1kIFsyyEFKTA5hPxLSNcttQ_bfQy0',
  );

  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode, // Auto-detect debug mode
        authOptions: const FlutterAuthClientOptions(
          autoRefreshToken: true,
        ),
      );
      debugPrint('✅ Supabase client initialized');
      if (kDebugMode) {
        debugPrint('   URL: $supabaseUrl');
      }
    } catch (e) {
      debugPrint('❌ Supabase initialization error: $e');
      rethrow;
    }
  }

  /// Get the current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get user ID
  static String? get userId => currentUser?.id;

  /// Sign out user
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}

/// Supabase table names
class SupabaseTables {
  static const String users = 'users';
  static const String foods = 'foods';
  static const String mealPlans = 'meal_plans';
  static const String mealItems = 'meal_items';
  static const String stores = 'stores';
  static const String foodPrices = 'food_prices';
  static const String userProgress = 'user_progress';
  static const String userFavorites = 'user_favorites';
  static const String userFeedback = 'user_feedback';
  static const String foodCategories = 'food_categories';
}
