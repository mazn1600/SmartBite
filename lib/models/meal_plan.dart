class MealPlan {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snack
  final List<MealItem> items;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalCost;
  final String? notes;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealPlan({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.items,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalCost,
    this.notes,
    this.rating = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'mealType': mealType,
      'items': items.map((item) => item.toJson()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalCost': totalCost,
      'notes': notes,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      mealType: json['mealType'],
      items: (json['items'] as List)
          .map((item) => MealItem.fromJson(item))
          .toList(),
      totalCalories: json['totalCalories'].toDouble(),
      totalProtein: json['totalProtein'].toDouble(),
      totalCarbs: json['totalCarbs'].toDouble(),
      totalFat: json['totalFat'].toDouble(),
      totalCost: json['totalCost'].toDouble(),
      notes: json['notes'],
      rating: json['rating']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class MealItem {
  final String id;
  final String foodId;
  final String foodName;
  final double quantity; // in grams
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double cost;
  final String? notes;

  MealItem({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.cost,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'quantity': quantity,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'cost': cost,
      'notes': notes,
    };
  }

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['id'],
      foodId: json['foodId'],
      foodName: json['foodName'],
      quantity: json['quantity'].toDouble(),
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      cost: json['cost'].toDouble(),
      notes: json['notes'],
    );
  }
}
