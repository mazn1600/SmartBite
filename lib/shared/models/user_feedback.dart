/// User Feedback model
///
/// Represents user feedback on meals, meal plans, or foods
class UserFeedback {
  final String id;
  final String userId;
  final String? mealPlanId;
  final String? foodId;
  final int? rating; // 1-5
  final String? feedbackText;
  final String? feedbackType; // e.g., 'meal', 'food', 'service'
  final DateTime createdAt;

  UserFeedback({
    required this.id,
    required this.userId,
    this.mealPlanId,
    this.foodId,
    this.rating,
    this.feedbackText,
    this.feedbackType,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meal_plan_id': mealPlanId,
      'food_id': foodId,
      'rating': rating,
      'feedback_text': feedbackText,
      'feedback_type': feedbackType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'] ?? json['id'],
      userId: json['user_id'] ?? json['userId'],
      mealPlanId: json['meal_plan_id'] ?? json['mealPlanId'],
      foodId: json['food_id'] ?? json['foodId'],
      rating: json['rating'] is int
          ? json['rating']
          : json['rating'] != null
              ? (json['rating'] as num).toInt()
              : null,
      feedbackText: json['feedback_text'] ?? json['feedbackText'],
      feedbackType: json['feedback_type'] ?? json['feedbackType'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  factory UserFeedback.fromMap(Map<String, dynamic> map) {
    return UserFeedback.fromJson(map);
  }

  UserFeedback copyWith({
    String? id,
    String? userId,
    String? mealPlanId,
    String? foodId,
    int? rating,
    String? feedbackText,
    String? feedbackType,
    DateTime? createdAt,
  }) {
    return UserFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      foodId: foodId ?? this.foodId,
      rating: rating ?? this.rating,
      feedbackText: feedbackText ?? this.feedbackText,
      feedbackType: feedbackType ?? this.feedbackType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

