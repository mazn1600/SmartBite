import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and client setup
class SupabaseConfig {
  static const String supabaseUrl = 'https://pnihaeljbyjiexnfolir.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBuaWhhZWxqYnlqaWV4bmZvbGlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEzNjgzMzgsImV4cCI6MjA3Njk0NDMzOH0.XANTGUKmfeIaRb1kIFsyyEFKTA5hPxLSNcttQ_bfQy0';

  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
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
