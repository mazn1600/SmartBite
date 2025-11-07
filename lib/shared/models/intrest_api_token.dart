/// Intrest API Token model for storing authentication tokens
///
/// Links Intrest API (Food Analysis API) tokens to user accounts
/// in Supabase database for persistence across devices.
class IntrestApiToken {
  final String id;
  final String userId;
  final String accessToken; // JWT token from Intrest API
  final String refreshToken; // Refresh token string
  final DateTime expiresAt; // Converted from expiresIn (milliseconds)
  final DateTime createdAt;
  final DateTime updatedAt;

  IntrestApiToken({
    required this.id,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if token is expired
  bool get isExpired {
    final now = DateTime.now();
    // Add 1 minute buffer for safety
    return now.isAfter(expiresAt.subtract(const Duration(minutes: 1)));
  }

  /// Check if token is valid (not expired)
  bool get isValid => !isExpired;

  /// Convert expiresIn (milliseconds timestamp) to DateTime
  static DateTime expiresInToDateTime(int expiresIn) {
    return DateTime.fromMillisecondsSinceEpoch(expiresIn);
  }

  /// Convert DateTime to milliseconds timestamp
  static int dateTimeToExpiresIn(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory IntrestApiToken.fromJson(Map<String, dynamic> json) {
    // Parse expires_at - required field
    DateTime expiresAt;
    if (json['expires_at'] != null) {
      expiresAt = DateTime.parse(json['expires_at']);
    } else if (json['expiresIn'] != null || json['expires_in'] != null) {
      final expiresIn = json['expiresIn'] ?? json['expires_in'];
      if (expiresIn is int && expiresIn > 0) {
        expiresAt = IntrestApiToken.expiresInToDateTime(expiresIn);
      } else {
        // Invalid expiresIn - default to 1 hour from now
        expiresAt = DateTime.now().add(const Duration(hours: 1));
      }
    } else {
      // No expiration data - default to 1 hour from now (safer than epoch)
      expiresAt = DateTime.now().add(const Duration(hours: 1));
    }

    return IntrestApiToken(
      id: json['id'] ?? json['id'],
      userId: json['user_id'] ?? json['userId'],
      accessToken: json['access_token'] ?? json['accessToken'],
      refreshToken: json['refresh_token'] ?? json['refreshToken'],
      expiresAt: expiresAt,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  factory IntrestApiToken.fromMap(Map<String, dynamic> map) {
    return IntrestApiToken.fromJson(map);
  }

  /// Create from Intrest API login response
  factory IntrestApiToken.fromLoginResponse({
    required String userId,
    required String accessToken,
    required String refreshToken,
    required int expiresIn, // milliseconds timestamp
  }) {
    return IntrestApiToken(
      id: '', // Will be set by database
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresInToDateTime(expiresIn),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  IntrestApiToken copyWith({
    String? id,
    String? userId,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IntrestApiToken(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

