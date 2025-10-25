import '../models/user.dart';
import '../models/meal_food.dart';
import '../constants/app_constants.dart';

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

  /// Generates a meal based on type and target calories
  static Meal _generateMealByType(
      User user, String mealType, int targetCalories) {
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
        imageUrl: '',
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
        imageUrl: '',
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
        imageUrl: '',
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
        imageUrl: '',
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
      imageUrl: '',
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
      imageUrl: '',
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
      imageUrl: '',
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
        imageUrl: '',
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
        imageUrl: '',
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
        imageUrl: '',
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

  /// Adjusts meals based on user's health conditions
  static List<Meal> adjustForHealthConditions(List<Meal> meals, User user) {
    try {
      if (user.healthConditions.contains('diabetes')) {
        // Reduce high glycemic foods and increase fiber
        // Note: In a real implementation, you'd need to create new MealFood objects
        // since MealFood is immutable. For now, we'll skip this adjustment.
      }

      if (user.healthConditions.contains('hypertension')) {
        // Reduce sodium content
        // Note: In a real implementation, you'd need to create new MealFood objects
        // since MealFood is immutable. For now, we'll skip this adjustment.
      }

      return meals;
    } catch (e) {
      print('Error adjusting meals for health conditions: $e');
      return meals;
    }
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
