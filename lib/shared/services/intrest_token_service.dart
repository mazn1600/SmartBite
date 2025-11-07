import '../models/intrest_api_token.dart';
import '../../core/config/supabase_config.dart';

/// Service for managing Intrest API tokens in Supabase database
///
/// Handles synchronization of tokens between local storage (SharedPreferences)
/// and Supabase database for persistence across devices.
class IntrestTokenService {
  static const String _tableName = 'intrest_api_tokens';

  /// Save tokens to Supabase database
  ///
  /// Creates or updates tokens for the current user.
  /// Returns the saved token or null if operation fails.
  static Future<IntrestApiToken?> saveTokens({
    required String userId,
    required String accessToken,
    required String refreshToken,
    required int expiresIn, // milliseconds timestamp
  }) async {
    try {
      final expiresAt = IntrestApiToken.expiresInToDateTime(expiresIn);

      // Check if token already exists for this user
      final existing = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final tokenData = {
        'user_id': userId,
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      IntrestApiToken token;

      if (existing != null) {
        // Update existing token
        final updated = await SupabaseConfig.client
            .from(_tableName)
            .update(tokenData)
            .eq('user_id', userId)
            .select()
            .single();

        token = IntrestApiToken.fromJson(updated);
      } else {
        // Create new token
        tokenData['created_at'] = DateTime.now().toIso8601String();
        final created = await SupabaseConfig.client
            .from(_tableName)
            .insert(tokenData)
            .select()
            .single();

        token = IntrestApiToken.fromJson(created);
      }

      return token;
    } catch (e) {
      print('❌ IntrestTokenService: Error saving tokens: $e');
      return null;
    }
  }

  /// Load tokens from Supabase database
  ///
  /// Retrieves tokens for the current user.
  /// Returns null if no tokens found or user not authenticated.
  static Future<IntrestApiToken?> loadTokens(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return IntrestApiToken.fromJson(response);
    } catch (e) {
      print('❌ IntrestTokenService: Error loading tokens: $e');
      return null;
    }
  }

  /// Clear tokens from Supabase database
  ///
  /// Removes tokens for the current user (on logout).
  static Future<bool> clearTokens(String userId) async {
    try {
      // Check if table exists first to avoid errors if migration hasn't been run
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('user_id', userId);

      return true;
    } catch (e) {
      // Table might not exist yet - this is OK, just log and continue
      if (e.toString().contains('table') && e.toString().contains('not found')) {
        print('ℹ️  IntrestTokenService: Table not found (migration not run yet) - skipping');
      } else {
        print('❌ IntrestTokenService: Error clearing tokens: $e');
      }
      return false; // Return false but don't throw - allow logout to continue
    }
  }

  /// Check if tokens exist for user
  static Future<bool> hasTokens(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ IntrestTokenService: Error checking tokens: $e');
      return false;
    }
  }

  /// Update tokens (for refresh scenarios)
  static Future<IntrestApiToken?> updateTokens({
    required String userId,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (accessToken != null) {
        updateData['access_token'] = accessToken;
      }
      if (refreshToken != null) {
        updateData['refresh_token'] = refreshToken;
      }
      if (expiresIn != null) {
        updateData['expires_at'] =
            IntrestApiToken.expiresInToDateTime(expiresIn).toIso8601String();
      }

      final updated = await SupabaseConfig.client
          .from(_tableName)
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();

      return IntrestApiToken.fromJson(updated);
    } catch (e) {
      print('❌ IntrestTokenService: Error updating tokens: $e');
      return null;
    }
  }
}

