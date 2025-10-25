import 'package:flutter/foundation.dart';
import '../models/meal_plan.dart';
import '../models/meal_food.dart';
import '../models/user.dart';
import '../utils/error_handler.dart';

/// Service for managing meal plans and meal planning functionality
class MealPlanService extends ChangeNotifier {
  List<MealPlan> _mealPlans = [];
  List<MealFood> _mealFoods = [];
  bool _isLoading = false;
  String? _error;

  List<MealPlan> get mealPlans => _mealPlans;
  List<MealFood> get mealFoods => _mealFoods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MealPlanService() {
    _initializeSampleData();
  }

  /// Initialize with sample meal plan data
  void _initializeSampleData() {
    _mealPlans = [
      MealPlan(
        id: '1',
        userId: 'user1',
        date: DateTime.now(),
        mealType: 'breakfast',
        items: [
          MealItem(
            id: '1',
            foodId: '1',
            foodName: 'Oatmeal with Berries',
            quantity: 100.0,
            calories: 300.0,
            protein: 12.0,
            carbs: 50.0,
            fat: 8.0,
            cost: 5.0,
            notes: 'Healthy breakfast option',
          ),
        ],
        totalCalories: 300.0,
        totalProtein: 12.0,
        totalCarbs: 50.0,
        totalFat: 8.0,
        totalCost: 5.0,
        notes: 'Healthy breakfast meal',
        rating: 4.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MealPlan(
        id: '2',
        userId: 'user1',
        date: DateTime.now(),
        mealType: 'lunch',
        items: [
          MealItem(
            id: '2',
            foodId: '2',
            foodName: 'Grilled Chicken Salad',
            quantity: 200.0,
            calories: 400.0,
            protein: 35.0,
            carbs: 15.0,
            fat: 20.0,
            cost: 12.0,
            notes: 'High protein lunch',
          ),
        ],
        totalCalories: 400.0,
        totalProtein: 35.0,
        totalCarbs: 15.0,
        totalFat: 20.0,
        totalCost: 12.0,
        notes: 'Balanced lunch meal',
        rating: 4.2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _mealFoods = [
      MealFood(
        id: '1',
        name: 'Oatmeal with Berries',
        calories: 300,
        protein: 12.0,
        carbs: 50.0,
        fat: 8.0,
        fiber: 8.0,
        sugar: 15.0,
        sodium: 5.0,
        servingSize: '1 cup',
        category: 'Breakfast',
        imageUrl: 'https://example.com/oatmeal.jpg',
      ),
      MealFood(
        id: '2',
        name: 'Grilled Chicken Salad',
        calories: 400,
        protein: 35.0,
        carbs: 15.0,
        fat: 20.0,
        fiber: 5.0,
        sugar: 8.0,
        sodium: 300.0,
        servingSize: '1 plate',
        category: 'Lunch',
        imageUrl: 'https://example.com/chicken_salad.jpg',
      ),
      MealFood(
        id: '3',
        name: 'Salmon with Quinoa',
        calories: 500,
        protein: 40.0,
        carbs: 45.0,
        fat: 25.0,
        fiber: 3.0,
        sugar: 2.0,
        sodium: 400.0,
        servingSize: '1 plate',
        category: 'Dinner',
        imageUrl: 'https://example.com/salmon_quinoa.jpg',
      ),
    ];
  }

  /// Create a new meal plan
  Result<MealPlan> createMealPlan({
    required String userId,
    required DateTime date,
    required String mealType,
    required List<MealItem> items,
    String? notes,
    double rating = 0.0,
  }) {
    try {
      if (userId.isEmpty) {
        return Result.error('User ID cannot be empty');
      }

      if (mealType.isEmpty) {
        return Result.error('Meal type cannot be empty');
      }

      if (items.isEmpty) {
        return Result.error('Meal plan must have at least one item');
      }

      // Calculate totals
      double totalCalories = 0.0;
      double totalProtein = 0.0;
      double totalCarbs = 0.0;
      double totalFat = 0.0;
      double totalCost = 0.0;

      for (final item in items) {
        totalCalories += item.calories;
        totalProtein += item.protein;
        totalCarbs += item.carbs;
        totalFat += item.fat;
        totalCost += item.cost;
      }

      final mealPlan = MealPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        date: date,
        mealType: mealType,
        items: items,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
        totalCost: totalCost,
        notes: notes,
        rating: rating,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _mealPlans.add(mealPlan);
      notifyListeners();

      return Result.success(mealPlan);
    } catch (e) {
      return Result.error('Error creating meal plan: ${e.toString()}');
    }
  }

  /// Get meal plan by ID
  Result<MealPlan> getMealPlanById(String mealPlanId) {
    try {
      if (mealPlanId.isEmpty) {
        return Result.error('Meal plan ID cannot be empty');
      }

      final mealPlan = _mealPlans.firstWhere(
        (plan) => plan.id == mealPlanId,
        orElse: () => throw Exception('Meal plan not found'),
      );

      return Result.success(mealPlan);
    } catch (e) {
      return Result.error('Error getting meal plan: ${e.toString()}');
    }
  }

  /// Get meal plans by user ID
  Result<List<MealPlan>> getMealPlansByUserId(String userId) {
    try {
      if (userId.isEmpty) {
        return Result.error('User ID cannot be empty');
      }

      final userMealPlans = _mealPlans
          .where((plan) => plan.userId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Result.success(userMealPlans);
    } catch (e) {
      return Result.error('Error getting user meal plans: ${e.toString()}');
    }
  }

  /// Get meal plans by date
  Result<List<MealPlan>> getMealPlansByDate(String userId, DateTime date) {
    try {
      if (userId.isEmpty) {
        return Result.error('User ID cannot be empty');
      }

      final dateMealPlans = _mealPlans
          .where((plan) =>
              plan.userId == userId &&
              plan.date.year == date.year &&
              plan.date.month == date.month &&
              plan.date.day == date.day)
          .toList()
        ..sort((a, b) => a.mealType.compareTo(b.mealType));

      return Result.success(dateMealPlans);
    } catch (e) {
      return Result.error('Error getting meal plans by date: ${e.toString()}');
    }
  }

  /// Update meal plan
  Result<MealPlan> updateMealPlan(
    String mealPlanId, {
    DateTime? date,
    String? mealType,
    List<MealItem>? items,
    String? notes,
    double? rating,
  }) {
    try {
      if (mealPlanId.isEmpty) {
        return Result.error('Meal plan ID cannot be empty');
      }

      final index = _mealPlans.indexWhere((plan) => plan.id == mealPlanId);
      if (index == -1) {
        return Result.error('Meal plan not found');
      }

      final existingPlan = _mealPlans[index];
      final updatedItems = items ?? existingPlan.items;

      // Recalculate totals if items changed
      double totalCalories = existingPlan.totalCalories;
      double totalProtein = existingPlan.totalProtein;
      double totalCarbs = existingPlan.totalCarbs;
      double totalFat = existingPlan.totalFat;
      double totalCost = existingPlan.totalCost;

      if (items != null) {
        totalCalories = 0.0;
        totalProtein = 0.0;
        totalCarbs = 0.0;
        totalFat = 0.0;
        totalCost = 0.0;

        for (final item in items) {
          totalCalories += item.calories;
          totalProtein += item.protein;
          totalCarbs += item.carbs;
          totalFat += item.fat;
          totalCost += item.cost;
        }
      }

      final updatedPlan = MealPlan(
        id: existingPlan.id,
        userId: existingPlan.userId,
        date: date ?? existingPlan.date,
        mealType: mealType ?? existingPlan.mealType,
        items: updatedItems,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
        totalCost: totalCost,
        notes: notes ?? existingPlan.notes,
        rating: rating ?? existingPlan.rating,
        createdAt: existingPlan.createdAt,
        updatedAt: DateTime.now(),
      );

      _mealPlans[index] = updatedPlan;
      notifyListeners();

      return Result.success(updatedPlan);
    } catch (e) {
      return Result.error('Error updating meal plan: ${e.toString()}');
    }
  }

  /// Delete meal plan
  Result<bool> deleteMealPlan(String mealPlanId) {
    try {
      if (mealPlanId.isEmpty) {
        return Result.error('Meal plan ID cannot be empty');
      }

      final index = _mealPlans.indexWhere((plan) => plan.id == mealPlanId);
      if (index == -1) {
        return Result.error('Meal plan not found');
      }

      _mealPlans.removeAt(index);
      notifyListeners();

      return Result.success(true);
    } catch (e) {
      return Result.error('Error deleting meal plan: ${e.toString()}');
    }
  }

  /// Add meal food to database
  Result<MealFood> addMealFood({
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
    required String imageUrl,
  }) {
    try {
      if (name.isEmpty) {
        return Result.error('Food name cannot be empty');
      }

      if (calories <= 0) {
        return Result.error('Calories must be greater than 0');
      }

      if (servingSize.isEmpty) {
        return Result.error('Serving size cannot be empty');
      }

      if (category.isEmpty) {
        return Result.error('Category cannot be empty');
      }

      final mealFood = MealFood(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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

      _mealFoods.add(mealFood);
      notifyListeners();

      return Result.success(mealFood);
    } catch (e) {
      return Result.error('Error adding meal food: ${e.toString()}');
    }
  }

  /// Get meal foods by category
  Result<List<MealFood>> getMealFoodsByCategory(String category) {
    try {
      if (category.isEmpty) {
        return Result.error('Category cannot be empty');
      }

      final foods = _mealFoods
          .where(
              (food) => food.category.toLowerCase() == category.toLowerCase())
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      return Result.success(foods);
    } catch (e) {
      return Result.error(
          'Error getting meal foods by category: ${e.toString()}');
    }
  }

  /// Search meal foods by name
  Result<List<MealFood>> searchMealFoods(String query) {
    try {
      if (query.isEmpty) {
        return Result.success(_mealFoods);
      }

      final foods = _mealFoods
          .where((food) =>
              food.name.toLowerCase().contains(query.toLowerCase()) ||
              food.category.toLowerCase().contains(query.toLowerCase()))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      return Result.success(foods);
    } catch (e) {
      return Result.error('Error searching meal foods: ${e.toString()}');
    }
  }

  /// Get all meal food categories
  Result<List<String>> getMealFoodCategories() {
    try {
      final categories =
          _mealFoods.map((food) => food.category).toSet().toList()..sort();

      return Result.success(categories);
    } catch (e) {
      return Result.error(
          'Error getting meal food categories: ${e.toString()}');
    }
  }

  /// Calculate daily nutrition summary
  Result<Map<String, double>> calculateDailyNutrition(
      String userId, DateTime date) {
    try {
      if (userId.isEmpty) {
        return Result.error('User ID cannot be empty');
      }

      final dayMealPlans = _mealPlans
          .where((plan) =>
              plan.userId == userId &&
              plan.date.year == date.year &&
              plan.date.month == date.month &&
              plan.date.day == date.day)
          .toList();

      double totalCalories = 0.0;
      double totalProtein = 0.0;
      double totalCarbs = 0.0;
      double totalFat = 0.0;
      double totalCost = 0.0;

      for (final plan in dayMealPlans) {
        totalCalories += plan.totalCalories;
        totalProtein += plan.totalProtein;
        totalCarbs += plan.totalCarbs;
        totalFat += plan.totalFat;
        totalCost += plan.totalCost;
      }

      return Result.success({
        'calories': totalCalories,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
        'cost': totalCost,
      });
    } catch (e) {
      return Result.error('Error calculating daily nutrition: ${e.toString()}');
    }
  }

  /// Generate meal plan based on user preferences
  Result<MealPlan> generateMealPlan({
    required User user,
    required DateTime date,
    required String mealType,
    required List<String> preferredCategories,
    required List<String> dietaryRestrictions,
  }) {
    try {
      if (mealType.isEmpty) {
        return Result.error('Meal type cannot be empty');
      }

      if (preferredCategories.isEmpty) {
        return Result.error('At least one preferred category must be selected');
      }

      // Filter foods by preferred categories and dietary restrictions
      var availableFoods = _mealFoods
          .where((food) => preferredCategories.contains(food.category))
          .toList();

      if (availableFoods.isEmpty) {
        return Result.error('No foods available for the selected categories');
      }

      // Create a simple meal plan with 2-3 items
      final selectedFoods = availableFoods.take(3).toList();
      final items = selectedFoods
          .map((food) => MealItem(
                id: DateTime.now().millisecondsSinceEpoch.toString() + food.id,
                foodId: food.id,
                foodName: food.name,
                quantity: 100.0, // Default quantity
                calories: food.calories.toDouble(),
                protein: food.protein,
                carbs: food.carbs,
                fat: food.fat,
                cost: 5.0, // Default cost
                notes: 'Generated meal item',
              ))
          .toList();

      // Calculate totals
      double totalCalories = 0.0;
      double totalProtein = 0.0;
      double totalCarbs = 0.0;
      double totalFat = 0.0;
      double totalCost = 0.0;

      for (final item in items) {
        totalCalories += item.calories;
        totalProtein += item.protein;
        totalCarbs += item.carbs;
        totalFat += item.fat;
        totalCost += item.cost;
      }

      final mealPlan = MealPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        date: date,
        mealType: mealType,
        items: items,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
        totalCost: totalCost,
        notes: 'Generated meal plan',
        rating: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _mealPlans.add(mealPlan);
      notifyListeners();

      return Result.success(mealPlan);
    } catch (e) {
      return Result.error('Error generating meal plan: ${e.toString()}');
    }
  }

  /// Get meal plan statistics
  Result<Map<String, dynamic>> getMealPlanStatistics(
      String userId, DateTime startDate, DateTime endDate) {
    try {
      if (userId.isEmpty) {
        return Result.error('User ID cannot be empty');
      }

      final periodMealPlans = _mealPlans
          .where((plan) =>
              plan.userId == userId &&
              plan.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              plan.date.isBefore(endDate.add(const Duration(days: 1))))
          .toList();

      if (periodMealPlans.isEmpty) {
        return Result.success({
          'totalMeals': 0,
          'totalCalories': 0.0,
          'totalProtein': 0.0,
          'totalCarbs': 0.0,
          'totalFat': 0.0,
          'totalCost': 0.0,
          'averageRating': 0.0,
          'days': 0,
        });
      }

      double totalCalories = 0.0;
      double totalProtein = 0.0;
      double totalCarbs = 0.0;
      double totalFat = 0.0;
      double totalCost = 0.0;
      double totalRating = 0.0;

      for (final plan in periodMealPlans) {
        totalCalories += plan.totalCalories;
        totalProtein += plan.totalProtein;
        totalCarbs += plan.totalCarbs;
        totalFat += plan.totalFat;
        totalCost += plan.totalCost;
        totalRating += plan.rating;
      }

      final days = endDate.difference(startDate).inDays + 1;
      final averageRating = totalRating / periodMealPlans.length;

      return Result.success({
        'totalMeals': periodMealPlans.length,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'totalCost': totalCost,
        'averageRating': averageRating,
        'days': days,
        'averageCaloriesPerDay': totalCalories / days,
      });
    } catch (e) {
      return Result.error(
          'Error getting meal plan statistics: ${e.toString()}');
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
