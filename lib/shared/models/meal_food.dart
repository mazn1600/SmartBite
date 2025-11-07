class MealFood {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final String servingSize;
  final String category;
  final String imageUrl;

  MealFood({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.servingSize,
    required this.category,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'servingSize': servingSize,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory MealFood.fromJson(Map<String, dynamic> json) {
    return MealFood(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Food',
      calories: json['calories'] ?? 0,
      protein: (json['protein'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      fiber: (json['fiber'] ?? 0.0).toDouble(),
      sugar: (json['sugar'] ?? 0.0).toDouble(),
      sodium: (json['sodium'] ?? 0.0).toDouble(),
      servingSize: json['servingSize'] ?? '1 serving',
      category: json['category'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  factory MealFood.fromMap(Map<String, dynamic> map) {
    return MealFood.fromJson(map);
  }
}
