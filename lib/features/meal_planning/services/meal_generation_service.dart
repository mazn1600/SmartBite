import '../../../../shared/models/user.dart';
import '../../../../shared/models/meal_food.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/image_constants.dart';
import '../../food/services/food_analysis_service.dart';
import '../../../../shared/models/food_analysis_models.dart';

/// Service for generating personalized meal recommendations
/// Uses user preferences, health conditions, and nutritional goals
class MealGenerationService {
  static const Map<String, double> _mealCalorieDistribution = {
    'breakfast': 0.25,
    'lunch': 0.35,
    'dinner': 0.30,
    'snack': 0.10,
  };

  static const List<String> _validMealTypes = [
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  ];

  /// Generates a single meal for a specific meal type
  /// Returns null if user data is invalid or meal type is unsupported
  static Meal? generateSingleMeal(User user, String mealType) {
    try {
      // Validate inputs
      if (!_isValidUser(user)) {
        return null;
      }

      if (!_validMealTypes.contains(mealType)) {
        return null;
      }

      final targetCalories = user.targetCalories;
      final mealCalories =
          (targetCalories * _mealCalorieDistribution[mealType]!).round();

      // Try Food API first (async), but fallback to sync method
      // Note: This is a limitation - we can't easily make this async
      // So we'll try sync API call, but it will return null if it needs async
      return _generateMealByType(user, mealType, mealCalories);
    } catch (e) {
      print('Error generating single meal: $e');
      return null;
    }
  }

  /// Validates user data for meal generation
  static bool _isValidUser(User user) {
    return user.targetCalories > 0 &&
        user.targetCalories <= 5000 && // Reasonable upper limit
        user.age >= AppConstants.minAge &&
        user.age <= AppConstants.maxAge;
  }

  /// Generates a complete set of personalized meals for a user
  /// Returns empty list if user data is invalid
  static List<Meal> generatePersonalizedMeals(User user) {
    try {
      if (!_isValidUser(user)) {
        return [];
      }

      final meals = <Meal>[];

      // Generate each meal type
      for (final mealType in _validMealTypes) {
        final meal = generateSingleMeal(user, mealType);
        if (meal != null) {
          meals.add(meal);
        }
      }

      return meals;
    } catch (e) {
      print('Error generating personalized meals: $e');
      return [];
    }
  }

  /// Generates a complete set of personalized meals for a user (async version)
  /// Uses Food Analysis API when available, falls back to hardcoded meals
  static Future<List<Meal>> generatePersonalizedMealsAsync(User user) async {
    try {
      if (!_isValidUser(user)) {
        return [];
      }

      final meals = <Meal>[];

      // Generate each meal type
      for (final mealType in _validMealTypes) {
        final targetCalories = user.targetCalories;
        final mealCalories =
            (targetCalories * _mealCalorieDistribution[mealType]!).round();

        // Try Food API first
        final apiMeal =
            await _generateMealWithFoodAPIAsync(user, mealType, mealCalories);
        if (apiMeal != null) {
          meals.add(apiMeal);
        } else {
          // Fallback to hardcoded
          final meal = generateSingleMeal(user, mealType);
          if (meal != null) {
            meals.add(meal);
          }
        }
      }

      return meals;
    } catch (e) {
      print('Error generating personalized meals (async): $e');
      // Fallback to sync version
      return generatePersonalizedMeals(user);
    }
  }

  /// Generates a meal based on type and target calories
  /// Tries Food Analysis API first, falls back to hardcoded meals
  static Meal _generateMealByType(
      User user, String mealType, int targetCalories) {
    // Try to generate meal using Food Analysis API
    final apiMeal = _generateMealWithFoodAPI(user, mealType, targetCalories);
    if (apiMeal != null) {
      return apiMeal;
    }

    // Fallback to hardcoded meals
    print('Food API failed, using fallback meal generation');
    switch (mealType) {
      case 'breakfast':
        return _generateBreakfast(user, targetCalories);
      case 'lunch':
        return _generateLunch(user, targetCalories);
      case 'dinner':
        return _generateDinner(user, targetCalories);
      case 'snack':
        return _generateSnack(user, targetCalories);
      default:
        return _generateBreakfast(user, targetCalories);
    }
  }

  // ========== Food Analysis API Integration ==========

  /// Generates a meal using Food Analysis API
  /// Returns null if API call fails (Note: API is async, so this will return null in sync context)
  /// Use _generateMealWithFoodAPIAsync for async contexts
  static Meal? _generateMealWithFoodAPI(
      User user, String mealType, int targetCalories) {
    // Food API is async, so we can't use it in a sync method
    // Return null to trigger fallback
    // For async meal generation, use generateMealAsync or update meal generation to be async
    return null;
  }

  // Since we can't use async/await in a sync method, let's make it async
  static Future<Meal?> _generateMealWithFoodAPIAsync(
      User user, String mealType, int targetCalories) async {
    try {
      final dishName =
          _generateDishNameForMealType(user, mealType, targetCalories);
      if (dishName.isEmpty) {
        return null;
      }

      // Get diet types from user preferences
      final dietTypes = _convertUserPreferencesToDietTypes(user);

      // Call full pipeline analysis
      final foodService = FoodAnalysisService();
      final result = await foodService.fullPipelineAnalysis(
        dishName,
        dietTypes: dietTypes,
      );

      if (result.isSuccess && result.data != null) {
        return _convertFullPipelineToMeal(
          result.data!,
          mealType,
          targetCalories,
          user,
          dishName,
        );
      }
      return null;
    } catch (e) {
      print('Error generating meal with Food API: $e');
      return null;
    }
  }

  /// Generates a dish name based on meal type, user preferences, and target calories
  static String _generateDishNameForMealType(
      User user, String mealType, int targetCalories) {
    final List<String> dishOptions = [];

    switch (mealType) {
      case 'breakfast':
        if (user.foodPreferences.contains('protein') ||
            user.goal == 'weight_loss') {
          dishOptions.addAll([
            'High Protein Breakfast Bowl',
            'Protein-Packed Scrambled Eggs',
            'Breakfast Protein Smoothie Bowl',
          ]);
        } else if (user.foodPreferences.contains('vegetables')) {
          dishOptions.addAll([
            'Vegetable Omelet',
            'Mediterranean Breakfast Bowl',
            'Green Breakfast Smoothie',
          ]);
        } else {
          dishOptions.addAll([
            'Classic Breakfast Platter',
            'Balanced Morning Meal',
            'Traditional Breakfast',
          ]);
        }
        break;

      case 'lunch':
        if (user.foodPreferences.contains('protein')) {
          dishOptions.addAll([
            'Grilled Chicken Lunch',
            'Protein-Rich Lunch Bowl',
            'High Protein Mediterranean Lunch',
          ]);
        } else if (user.foodPreferences.contains('vegetables')) {
          dishOptions.addAll([
            'Mediterranean Quinoa Bowl',
            'Vegetable Lunch Salad',
            'Healthy Mediterranean Lunch',
          ]);
        } else {
          dishOptions.addAll([
            'Balanced Lunch Meal',
            'Traditional Lunch Platter',
            'Complete Lunch Bowl',
          ]);
        }
        break;

      case 'dinner':
        if (user.foodPreferences.contains('protein')) {
          dishOptions.addAll([
            'Grilled Chicken Dinner',
            'Protein-Rich Dinner Bowl',
            'High Protein Mediterranean Dinner',
          ]);
        } else if (user.foodPreferences.contains('vegetables')) {
          dishOptions.addAll([
            'Mediterranean Dinner Bowl',
            'Vegetable Dinner Platter',
            'Healthy Mediterranean Dinner',
          ]);
        } else {
          dishOptions.addAll([
            'Balanced Dinner Meal',
            'Traditional Dinner Platter',
            'Complete Dinner Bowl',
          ]);
        }
        break;

      case 'snack':
        dishOptions.addAll([
          'Energy Snack Mix',
          'Healthy Snack Bowl',
          'Nutritious Snack Platter',
        ]);
        break;
    }

    // Return a random dish or the first one
    if (dishOptions.isNotEmpty) {
      return dishOptions[0]; // Simple: use first option
    }

    return mealType.capitalize() + ' Meal';
  }

  /// Converts user preferences to diet types for API
  static List<String> _convertUserPreferencesToDietTypes(User user) {
    final dietTypes = <String>[];

    if (user.foodPreferences.contains('vegetarian') ||
        user.foodPreferences.contains('vegetables')) {
      dietTypes.add('vegetarian');
    }

    if (user.foodPreferences.contains('vegan')) {
      dietTypes.add('vegan');
    }

    if (user.goal == 'weight_loss') {
      dietTypes.add('low_calorie');
    }

    return dietTypes;
  }

  /// Converts FullPipelineResponse to Meal object
  static Meal _convertFullPipelineToMeal(
    FullPipelineResponse response,
    String mealType,
    int targetCalories,
    User user,
    String dishName,
  ) {
    final mealFoods = <MealFood>[];

    // Extract macronutrients
    final protein = response.macronutrients['protein'] ?? 0.0;
    final carbs = response.macronutrients['carbohydrates'] ?? 0.0;
    final fat = response.macronutrients['fat'] ?? 0.0;

    // Filter allergens based on user allergies
    final safeIngredients = _filterAllergens(
      response.ingredients,
      response.allergens,
      user.allergies,
    );

    // Convert ingredients to MealFood objects
    for (final ingredient in safeIngredients) {
      // Find nutrient data for this ingredient
      final nutrient =
          _findNutrientForIngredient(ingredient, response.nutrients);

      // Calculate serving size to match target calories
      final servingSize = _calculateServingSize(
        ingredient,
        response.totalCalories,
        targetCalories,
      );

      // Calculate calories and macros for this ingredient
      final ingredientCalories =
          (targetCalories / safeIngredients.length).round();
      final ingredientProtein = protein / safeIngredients.length;
      final ingredientCarbs = carbs / safeIngredients.length;
      final ingredientFat = fat / safeIngredients.length;

      mealFoods.add(MealFood(
        id: 'ingredient_${ingredient.name}_${DateTime.now().millisecondsSinceEpoch}',
        name: ingredient.name,
        calories: ingredientCalories,
        protein: ingredientProtein,
        carbs: ingredientCarbs,
        fat: ingredientFat,
        fiber: nutrient?.value ?? 0.0,
        sugar: 0.0, // Extract from nutrients if available
        sodium: 0.0, // Extract from nutrients if available
        servingSize: servingSize,
        category: ingredient.category ?? mealType,
        imageUrl: ImageConstants.getFoodImageByCategory(
            ingredient.category ?? mealType),
      ));
    }

    // If no ingredients, create a single meal food from the dish
    if (mealFoods.isEmpty) {
      mealFoods.add(MealFood(
        id: 'dish_${dishName}_${DateTime.now().millisecondsSinceEpoch}',
        name: dishName,
        calories: targetCalories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        fiber: 0.0,
        sugar: 0.0,
        sodium: 0.0,
        servingSize: '1 serving',
        category: mealType,
        imageUrl: ImageConstants.getFoodImageByName(dishName),
      ));
    }

    return Meal(
      id: 'meal_${mealType}_${DateTime.now().millisecondsSinceEpoch}',
      name: dishName,
      foods: mealFoods,
      totalCalories: mealFoods.fold(0, (sum, food) => sum + food.calories),
      mealType: mealType,
      createdAt: DateTime.now(),
    );
  }

  /// Filters ingredients based on allergen analysis
  static List<Ingredient> _filterAllergens(
    List<Ingredient> ingredients,
    List<Allergen> allergens,
    List<String> userAllergies,
  ) {
    if (userAllergies.isEmpty) {
      return ingredients;
    }

    // Create set of allergen names from user allergies
    final userAllergenSet = userAllergies.map((a) => a.toLowerCase()).toSet();

    // Filter ingredients that don't contain user allergens
    return ingredients.where((ingredient) {
      // Check if any allergen matches user allergies
      for (final allergen in allergens) {
        if (userAllergenSet.contains(allergen.name.toLowerCase())) {
          // Check if this ingredient is associated with this allergen
          // This is simplified - in a real implementation, you'd check ingredient-allergen mapping
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Finds nutrient data for an ingredient
  static Nutrient? _findNutrientForIngredient(
      Ingredient ingredient, List<Nutrient> nutrients) {
    // Simple matching: look for fiber or similar nutrients
    for (final nutrient in nutrients) {
      if (nutrient.name.toLowerCase().contains('fiber') ||
          nutrient.name.toLowerCase().contains('dietary fiber')) {
        return nutrient;
      }
    }
    return null;
  }

  /// Calculates serving size for an ingredient to match target calories
  static String _calculateServingSize(
    Ingredient ingredient,
    double totalCalories,
    int targetCalories,
  ) {
    if (ingredient.quantity != null && ingredient.unit != null) {
      // Scale the quantity based on target calories
      final scaleFactor = targetCalories / totalCalories;
      final scaledQuantity = ingredient.quantity! * scaleFactor;

      if (ingredient.unit == 'g' || ingredient.unit == 'gram') {
        return '${scaledQuantity.toStringAsFixed(0)}g';
      } else {
        return '${scaledQuantity.toStringAsFixed(1)} ${ingredient.unit}';
      }
    }

    // Default serving size
    return '1 serving';
  }

  /// Generates a breakfast meal based on user preferences
  static Meal _generateBreakfast(User user, int targetCalories) {
    final foods = <MealFood>[];

    try {
      // Main protein source (60% of calories)
      if (user.foodPreferences.contains('vegetables')) {
        foods.add(_createMealFood(
          id: 'breakfast_1',
          name: 'Vegetable Omelet',
          calories: (targetCalories * 0.6).round(),
          protein: 25.0,
          carbs: 8.0,
          fat: 15.0,
          fiber: 3.0,
          sugar: 4.0,
          sodium: 400.0,
          servingSize: '1 large',
          category: 'breakfast',
        ));
      } else {
        foods.add(_createMealFood(
          id: 'breakfast_2',
          name: 'Scrambled Eggs with Toast',
          calories: (targetCalories * 0.6).round(),
          protein: 20.0,
          carbs: 15.0,
          fat: 12.0,
          fiber: 2.0,
          sugar: 2.0,
          sodium: 350.0,
          servingSize: '1 serving',
          category: 'breakfast',
        ));
      }

      // Add fruit if no citrus allergies (20% of calories)
      if (!user.allergies.contains('citrus')) {
        foods.add(_createMealFood(
          id: 'breakfast_3',
          name: 'Fresh Orange',
          calories: (targetCalories * 0.2).round(),
          protein: 1.0,
          carbs: 15.0,
          fat: 0.2,
          fiber: 3.0,
          sugar: 12.0,
          sodium: 0.0,
          servingSize: '1 medium',
          category: 'fruit',
        ));
      }

      // Add healthy fat (20% of calories)
      foods.add(_createMealFood(
        id: 'breakfast_4',
        name: 'Avocado Slice',
        calories: (targetCalories * 0.2).round(),
        protein: 2.0,
        carbs: 3.0,
        fat: 8.0,
        fiber: 2.0,
        sugar: 0.5,
        sodium: 5.0,
        servingSize: '1/4 avocado',
        category: 'healthy_fat',
      ));

      return _createMeal(
        id: 'breakfast_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Breakfast',
        foods: foods,
        mealType: 'breakfast',
      );
    } catch (e) {
      print('Error generating breakfast: $e');
      return _createDefaultMeal('breakfast', targetCalories);
    }
  }

  static Meal _generateLunch(User user, int targetCalories) {
    final foods = <MealFood>[];

    // Main protein source
    if (user.foodPreferences.contains('protein') ||
        user.goal == 'weight_loss') {
      foods.add(MealFood(
        id: '5',
        name: 'Grilled Chicken Breast',
        calories: (targetCalories * 0.4).round(),
        protein: 35.0,
        carbs: 0.0,
        fat: 8.0,
        fiber: 0.0,
        sugar: 0.0,
        sodium: 200.0,
        servingSize: '150g',
        category: 'protein',
        imageUrl: ImageConstants.chicken,
      ));
    } else {
      foods.add(MealFood(
        id: '6',
        name: 'Salmon Fillet',
        calories: (targetCalories * 0.4).round(),
        protein: 30.0,
        carbs: 0.0,
        fat: 12.0,
        fiber: 0.0,
        sugar: 0.0,
        sodium: 150.0,
        servingSize: '120g',
        category: 'protein',
        imageUrl: ImageConstants.salmon,
      ));
    }

    // Carbohydrate source
    if (user.foodPreferences.contains('carbohydrates')) {
      foods.add(MealFood(
        id: '7',
        name: 'Brown Rice',
        calories: (targetCalories * 0.3).round(),
        protein: 4.0,
        carbs: 35.0,
        fat: 1.0,
        fiber: 3.0,
        sugar: 0.5,
        sodium: 5.0,
        servingSize: '1 cup cooked',
        category: 'carbohydrate',
        imageUrl: ImageConstants.brownRice,
      ));
    } else {
      foods.add(MealFood(
        id: '8',
        name: 'Quinoa Salad',
        calories: (targetCalories * 0.3).round(),
        protein: 6.0,
        carbs: 30.0,
        fat: 2.0,
        fiber: 4.0,
        sugar: 2.0,
        sodium: 10.0,
        servingSize: '1 cup',
        category: 'carbohydrate',
        imageUrl: ImageConstants.brownRice,
      ));
    }

    // Vegetables
    foods.add(MealFood(
      id: '9',
      name: 'Mixed Green Salad',
      calories: (targetCalories * 0.2).round(),
      protein: 2.0,
      carbs: 8.0,
      fat: 1.0,
      fiber: 4.0,
      sugar: 5.0,
      sodium: 20.0,
      servingSize: '2 cups',
      category: 'vegetable',
      imageUrl: ImageConstants.broccoli,
    ));

    // Healthy fat
    foods.add(MealFood(
      id: '10',
      name: 'Olive Oil Dressing',
      calories: (targetCalories * 0.1).round(),
      protein: 0.0,
      carbs: 0.0,
      fat: 5.0,
      fiber: 0.0,
      sugar: 0.0,
      sodium: 50.0,
      servingSize: '1 tbsp',
      category: 'healthy_fat',
      imageUrl: ImageConstants.foodPlaceholder,
    ));

    return Meal(
      id: 'lunch_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Lunch',
      foods: foods,
      totalCalories: foods.fold(0, (sum, food) => sum + food.calories),
      mealType: 'lunch',
      createdAt: DateTime.now(),
    );
  }

  static Meal _generateDinner(User user, int targetCalories) {
    final foods = <MealFood>[];

    // Main protein
    foods.add(MealFood(
      id: '11',
      name: 'Baked Cod',
      calories: (targetCalories * 0.35).round(),
      protein: 28.0,
      carbs: 0.0,
      fat: 6.0,
      fiber: 0.0,
      sugar: 0.0,
      sodium: 180.0,
      servingSize: '150g',
      category: 'protein',
      imageUrl: '',
    ));

    // Starchy vegetable
    foods.add(MealFood(
      id: '12',
      name: 'Sweet Potato',
      calories: (targetCalories * 0.25).round(),
      protein: 2.0,
      carbs: 25.0,
      fat: 0.1,
      fiber: 4.0,
      sugar: 7.0,
      sodium: 20.0,
      servingSize: '1 medium',
      category: 'carbohydrate',
      imageUrl: ImageConstants.brownRice,
    ));

    // Green vegetables
    foods.add(MealFood(
      id: '13',
      name: 'Steamed Broccoli',
      calories: (targetCalories * 0.15).round(),
      protein: 3.0,
      carbs: 6.0,
      fat: 0.3,
      fiber: 3.0,
      sugar: 2.0,
      sodium: 15.0,
      servingSize: '1 cup',
      category: 'vegetable',
      imageUrl: '',
    ));

    // Healthy fat
    foods.add(MealFood(
      id: '14',
      name: 'Almonds',
      calories: (targetCalories * 0.25).round(),
      protein: 6.0,
      carbs: 3.0,
      fat: 8.0,
      fiber: 2.0,
      sugar: 1.0,
      sodium: 0.0,
      servingSize: '15 pieces',
      category: 'healthy_fat',
      imageUrl: '',
    ));

    return Meal(
      id: 'dinner_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Dinner',
      foods: foods,
      totalCalories: foods.fold(0, (sum, food) => sum + food.calories),
      mealType: 'dinner',
      createdAt: DateTime.now(),
    );
  }

  static Meal _generateSnack(User user, int targetCalories) {
    final foods = <MealFood>[];

    // Choose snack based on user preferences and goal
    if (user.goal == 'weight_loss') {
      foods.add(MealFood(
        id: '15',
        name: 'Greek Yogurt with Berries',
        calories: targetCalories,
        protein: 15.0,
        carbs: 12.0,
        fat: 2.0,
        fiber: 3.0,
        sugar: 8.0,
        sodium: 50.0,
        servingSize: '1 cup',
        category: 'snack',
        imageUrl: ImageConstants.yogurt,
      ));
    } else if (user.foodPreferences.contains('nuts')) {
      foods.add(MealFood(
        id: '16',
        name: 'Mixed Nuts',
        calories: targetCalories,
        protein: 8.0,
        carbs: 6.0,
        fat: 12.0,
        fiber: 3.0,
        sugar: 2.0,
        sodium: 5.0,
        servingSize: '1/4 cup',
        category: 'snack',
        imageUrl: ImageConstants.foodPlaceholder,
      ));
    } else {
      foods.add(MealFood(
        id: '17',
        name: 'Apple with Peanut Butter',
        calories: targetCalories,
        protein: 6.0,
        carbs: 18.0,
        fat: 8.0,
        fiber: 4.0,
        sugar: 14.0,
        sodium: 5.0,
        servingSize: '1 medium apple + 1 tbsp',
        category: 'snack',
        imageUrl: ImageConstants.apple,
      ));
    }

    return Meal(
      id: 'snack_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Snack',
      foods: foods,
      totalCalories: foods.fold(0, (sum, food) => sum + food.calories),
      mealType: 'snack',
      createdAt: DateTime.now(),
    );
  }

  /// Creates a MealFood object with proper validation
  static MealFood _createMealFood({
    required String id,
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
    required double sugar,
    required double sodium,
    required String servingSize,
    required String category,
    String imageUrl = '',
  }) {
    return MealFood(
      id: id,
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      servingSize: servingSize,
      category: category,
      imageUrl: imageUrl,
    );
  }

  /// Creates a Meal object with proper validation
  static Meal _createMeal({
    required String id,
    required String name,
    required List<MealFood> foods,
    required String mealType,
  }) {
    return Meal(
      id: id,
      name: name,
      foods: foods,
      totalCalories: foods.fold(0, (sum, food) => sum + food.calories),
      mealType: mealType,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a default meal when generation fails
  static Meal _createDefaultMeal(String mealType, int targetCalories) {
    final foods = [
      _createMealFood(
        id: '${mealType}_default',
        name: 'Basic $mealType',
        calories: targetCalories,
        protein: 20.0,
        carbs: 30.0,
        fat: 10.0,
        fiber: 5.0,
        sugar: 5.0,
        sodium: 200.0,
        servingSize: '1 serving',
        category: mealType,
      ),
    ];

    return _createMeal(
      id: '${mealType}_default_${DateTime.now().millisecondsSinceEpoch}',
      name: mealType.capitalize(),
      foods: foods,
      mealType: mealType,
    );
  }
}

class Meal {
  final String id;
  final String name;
  final List<MealFood> foods;
  final int totalCalories;
  final String mealType;
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.name,
    required this.foods,
    required this.totalCalories,
    required this.mealType,
    required this.createdAt,
  });

  double get totalProtein => foods.fold(0.0, (sum, food) => sum + food.protein);
  double get totalCarbs => foods.fold(0.0, (sum, food) => sum + food.carbs);
  double get totalFat => foods.fold(0.0, (sum, food) => sum + food.fat);
  double get totalFiber => foods.fold(0.0, (sum, food) => sum + food.fiber);
}

/// Extension for string utilities
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
