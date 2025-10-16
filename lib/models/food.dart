class Food {
  final String id;
  final String name;
  final String nameArabic;
  final String category;
  final String description;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double sugarPer100g;
  final double sodiumPer100g;
  final Map<String, double> vitamins;
  final Map<String, double> minerals;
  final List<String> allergens;
  final String imageUrl;
  final String recipeInstructions;
  final int preparationTime; // in minutes
  final int servings;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Food({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.category,
    required this.description,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.fiberPer100g,
    required this.sugarPer100g,
    required this.sodiumPer100g,
    this.vitamins = const {},
    this.minerals = const {},
    this.allergens = const [],
    required this.imageUrl,
    required this.recipeInstructions,
    required this.preparationTime,
    required this.servings,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate nutrition for a specific serving size
  Map<String, double> getNutritionForServing(double servingSizeGrams) {
    final multiplier = servingSizeGrams / 100;
    return {
      'calories': caloriesPer100g * multiplier,
      'protein': proteinPer100g * multiplier,
      'carbs': carbsPer100g * multiplier,
      'fat': fatPer100g * multiplier,
      'fiber': fiberPer100g * multiplier,
      'sugar': sugarPer100g * multiplier,
      'sodium': sodiumPer100g * multiplier,
    };
  }

  // Get macronutrient percentages
  Map<String, double> getMacroPercentages() {
    final totalCalories = caloriesPer100g;
    return {
      'protein': (proteinPer100g * 4) / totalCalories * 100,
      'carbs': (carbsPer100g * 4) / totalCalories * 100,
      'fat': (fatPer100g * 9) / totalCalories * 100,
    };
  }

  // Check if food contains allergens
  bool containsAllergen(String allergen) {
    return allergens.any((a) => a.toLowerCase().contains(allergen.toLowerCase()));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'category': category,
      'description': description,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'fiberPer100g': fiberPer100g,
      'sugarPer100g': sugarPer100g,
      'sodiumPer100g': sodiumPer100g,
      'vitamins': vitamins,
      'minerals': minerals,
      'allergens': allergens,
      'imageUrl': imageUrl,
      'recipeInstructions': recipeInstructions,
      'preparationTime': preparationTime,
      'servings': servings,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      nameArabic: json['nameArabic'],
      category: json['category'],
      description: json['description'],
      caloriesPer100g: json['caloriesPer100g'].toDouble(),
      proteinPer100g: json['proteinPer100g'].toDouble(),
      carbsPer100g: json['carbsPer100g'].toDouble(),
      fatPer100g: json['fatPer100g'].toDouble(),
      fiberPer100g: json['fiberPer100g'].toDouble(),
      sugarPer100g: json['sugarPer100g'].toDouble(),
      sodiumPer100g: json['sodiumPer100g'].toDouble(),
      vitamins: Map<String, double>.from(json['vitamins'] ?? {}),
      minerals: Map<String, double>.from(json['minerals'] ?? {}),
      allergens: List<String>.from(json['allergens'] ?? []),
      imageUrl: json['imageUrl'],
      recipeInstructions: json['recipeInstructions'],
      preparationTime: json['preparationTime'],
      servings: json['servings'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
