import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../utils/error_handler.dart';

/// Service for Supabase database operations
class SupabaseService {
  static SupabaseClient get _client => SupabaseConfig.client;

  /// Generic method to handle Supabase operations with error handling
  static Future<Result<T>> _handleOperation<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      final result = await operation();
      return Result.success(result);
    } on PostgrestException catch (e) {
      return Result.error('Database error in $operationName: ${e.message}');
    } on AuthException catch (e) {
      return Result.error(
          'Authentication error in $operationName: ${e.message}');
    } on Exception catch (e) {
      return Result.error('Error in $operationName: ${e.toString()}');
    }
  }

  /// Insert a record into a table
  static Future<Result<Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    return _handleOperation(
      () async {
        final response =
            await _client.from(table).insert(data).select().single();
        return response;
      },
      'insert into $table',
    );
  }

  /// Insert multiple records into a table
  static Future<Result<List<Map<String, dynamic>>>> insertMany(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    return _handleOperation(
      () async {
        final response = await _client.from(table).insert(data).select();
        return response;
      },
      'insert many into $table',
    );
  }

  /// Select all records from a table
  static Future<Result<List<Map<String, dynamic>>>> selectAll(
      String table) async {
    return _handleOperation(
      () async {
        final response = await _client.from(table).select();
        return response;
      },
      'select all from $table',
    );
  }

  /// Select records with a simple filter
  static Future<Result<List<Map<String, dynamic>>>> selectWhere(
    String table,
    String column,
    dynamic value,
  ) async {
    return _handleOperation(
      () async {
        final response = await _client.from(table).select().eq(column, value);
        return response;
      },
      'select where from $table',
    );
  }

  /// Select records with text search
  static Future<Result<List<Map<String, dynamic>>>> selectWithTextSearch(
    String table,
    String column,
    String searchTerm,
  ) async {
    return _handleOperation(
      () async {
        final response =
            await _client.from(table).select().ilike(column, '%$searchTerm%');
        return response;
      },
      'select with text search from $table',
    );
  }

  /// Select a single record by ID
  static Future<Result<Map<String, dynamic>>> selectById(
    String table,
    String id,
  ) async {
    return _handleOperation(
      () async {
        final response =
            await _client.from(table).select().eq('id', id).single();
        return response;
      },
      'select by id from $table',
    );
  }

  /// Update a record by ID
  static Future<Result<Map<String, dynamic>>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    return _handleOperation(
      () async {
        final response = await _client
            .from(table)
            .update(data)
            .eq('id', id)
            .select()
            .single();
        return response;
      },
      'update $table',
    );
  }

  /// Delete a record by ID
  static Future<Result<bool>> delete(
    String table,
    String id,
  ) async {
    return _handleOperation(
      () async {
        await _client.from(table).delete().eq('id', id);
        return true;
      },
      'delete from $table',
    );
  }

  /// Upsert (insert or update) a record
  static Future<Result<Map<String, dynamic>>> upsert(
    String table,
    Map<String, dynamic> data, {
    String? onConflict,
  }) async {
    return _handleOperation(
      () async {
        final response = await _client
            .from(table)
            .upsert(data, onConflict: onConflict)
            .select()
            .single();
        return response;
      },
      'upsert into $table',
    );
  }

  /// Subscribe to real-time changes
  static RealtimeChannel subscribeToTable(
    String table,
    void Function(Map<String, dynamic>) onInsert,
    void Function(Map<String, dynamic>) onUpdate,
    void Function(Map<String, dynamic>) onDelete,
  ) {
    return _client
        .channel('$table-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: table,
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: table,
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
  }

  /// Unsubscribe from real-time changes
  static Future<void> unsubscribe(RealtimeChannel channel) async {
    await channel.unsubscribe();
  }
}
