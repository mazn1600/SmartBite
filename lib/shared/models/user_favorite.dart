/// User Favorite model
///
/// Represents a food item that a user has marked as favorite
class UserFavorite {
  final String id;
  final String userId;
  final String foodId;
  final DateTime createdAt;

  UserFavorite({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'food_id': foodId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory UserFavorite.fromJson(Map<String, dynamic> json) {
    return UserFavorite(
      id: json['id'] ?? json['id'],
      userId: json['user_id'] ?? json['userId'],
      foodId: json['food_id'] ?? json['foodId'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  factory UserFavorite.fromMap(Map<String, dynamic> map) {
    return UserFavorite.fromJson(map);
  }

  UserFavorite copyWith({
    String? id,
    String? userId,
    String? foodId,
    DateTime? createdAt,
  }) {
    return UserFavorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodId: foodId ?? this.foodId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

