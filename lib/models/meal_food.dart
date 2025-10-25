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
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber'].toDouble(),
      sugar: json['sugar'].toDouble(),
      sodium: json['sodium'].toDouble(),
      servingSize: json['servingSize'],
      category: json['category'],
      imageUrl: json['imageUrl'],
    );
  }

  factory MealFood.fromMap(Map<String, dynamic> map) {
    return MealFood.fromJson(map);
  }
}
