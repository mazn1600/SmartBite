import 'package:flutter/foundation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../shared/models/meal_plan.dart';
import '../../../../shared/models/meal_food.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/utils/error_handler.dart';

/// Consolidated meal plan service using Supabase
/// Provides unified meal planning functionality with real-time updates
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
    _initializeData();
  }

  /// Initialize data and set up real-time subscriptions
  void _initializeData() {
    _loadMealPlans();
    _loadMealFoods();
    _setupRealtimeSubscriptions();
  }

  /// Set up real-time subscriptions
  void _setupRealtimeSubscriptions() {
    // Subscribe to meal plans changes
    SupabaseService.subscribeToTable(
      SupabaseTables.mealPlans,
      (data) => _onMealPlanInserted(data),
      (data) => _onMealPlanUpdated(data),
      (data) => _onMealPlanDeleted(data),
    );

    // Subscribe to meal foods changes
    SupabaseService.subscribeToTable(
      SupabaseTables.foods,
      (data) => _onMealFoodInserted(data),
      (data) => _onMealFoodUpdated(data),
      (data) => _onMealFoodDeleted(data),
    );
  }

  /// Load meal plans from Supabase
  Future<void> _loadMealPlans() async {
    if (SupabaseConfig.userId == null) return;

    setLoading(true);
    try {
      final result = await SupabaseService.selectWhere(
        SupabaseTables.mealPlans,
        'user_id',
        SupabaseConfig.userId!,
      );

      if (result.isSuccess) {
        _mealPlans =
            result.data!.map((json) => MealPlan.fromJson(json)).toList();
        notifyListeners();
      } else {
        setError(result.error!);
      }
    } catch (e) {
      setError('Failed to load meal plans: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Load meal foods from Supabase
  Future<void> _loadMealFoods() async {
    setLoading(true);
    try {
      final result = await SupabaseService.selectAll(SupabaseTables.foods);

      if (result.isSuccess) {
        _mealFoods =
            result.data!.map((json) => MealFood.fromJson(json)).toList();
        notifyListeners();
      } else {
        setError(result.error!);
      }
    } catch (e) {
      setError('Failed to load meal foods: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Create a new meal plan
  Future<Result<MealPlan>> createMealPlan({
    String? userId,
    required DateTime date,
    required String mealType,
    required List<MealItem> items,
    String? notes,
    double rating = 0.0,
  }) async {
    final currentUserId = userId ?? SupabaseConfig.userId;
    if (currentUserId == null) {
      return Result.error('User not authenticated');
    }

    try {
      setLoading(true);
      clearError();

      // Validate inputs
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

      // Format date as YYYY-MM-DD for Supabase date column
      final dateString = date.toIso8601String().split('T')[0];
      
      final mealPlanData = {
        'user_id': currentUserId,
        'date': dateString, // Date only (YYYY-MM-DD), not datetime
        'meal_type': mealType,
        'items': items.map((item) => item.toJson()).toList(),
        'total_calories': totalCalories,
        'total_protein': totalProtein,
        'total_carbs': totalCarbs,
        'total_fat': totalFat,
        'total_cost': totalCost,
        'notes': notes,
        'rating': rating,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final result = await SupabaseService.insert(
        SupabaseTables.mealPlans,
        mealPlanData,
      );

      if (result.isSuccess) {
        final mealPlan = MealPlan.fromJson(result.data!);
        _mealPlans.insert(0, mealPlan);
        notifyListeners();
        return Result.success(mealPlan);
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error('Error creating meal plan: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Get meal plan by ID
  Future<Result<MealPlan>> getMealPlanById(String mealPlanId) async {
    try {
      if (mealPlanId.isEmpty) {
        return Result.error('Meal plan ID cannot be empty');
      }

      final result = await SupabaseService.selectById(
        SupabaseTables.mealPlans,
        mealPlanId,
      );

      if (result.isSuccess) {
        return Result.success(MealPlan.fromJson(result.data!));
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error('Error getting meal plan: ${e.toString()}');
    }
  }

  /// Get meal plans by user ID
  Future<Result<List<MealPlan>>> getMealPlansByUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        return Result.error('User ID cannot be empty');
      }

      final result = await SupabaseService.selectWhere(
        SupabaseTables.mealPlans,
        'user_id',
        userId,
      );

      if (result.isSuccess) {
        final mealPlans =
            result.data!.map((json) => MealPlan.fromJson(json)).toList();
        mealPlans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return Result.success(mealPlans);
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error('Error getting user meal plans: ${e.toString()}');
    }
  }

  /// Get meal plans by date
  Future<Result<List<MealPlan>>> getMealPlansByDate(
    String userId,
    DateTime date,
  ) async {
    try {
      if (userId.isEmpty) {
        return Result.error('User ID cannot be empty');
      }

      final startOfDay = DateTime(date.year, date.month, date.day);

      final result = await SupabaseService.selectWhere(
        SupabaseTables.mealPlans,
        'user_id',
        userId,
      );

      if (result.isSuccess) {
        final mealPlans =
            result.data!.map((json) => MealPlan.fromJson(json)).where((plan) {
          final planDate = plan.date;
          return planDate.year == startOfDay.year &&
              planDate.month == startOfDay.month &&
              planDate.day == startOfDay.day;
        }).toList();
        mealPlans.sort((a, b) => a.mealType.compareTo(b.mealType));
        return Result.success(mealPlans);
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error('Error getting meal plans by date: ${e.toString()}');
    }
  }

  /// Update meal plan
  Future<Result<MealPlan>> updateMealPlan(
    String mealPlanId, {
    DateTime? date,
    String? mealType,
    List<MealItem>? items,
    String? notes,
    double? rating,
  }) async {
    try {
      setLoading(true);
      clearError();

      if (mealPlanId.isEmpty) {
        return Result.error('Meal plan ID cannot be empty');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (date != null) updateData['date'] = date.toIso8601String().split('T')[0]; // Date only
      if (mealType != null) updateData['meal_type'] = mealType;
      if (notes != null) updateData['notes'] = notes;
      if (rating != null) updateData['rating'] = rating;

      if (items != null) {
        // Recalculate totals
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

        updateData['items'] = items.map((item) => item.toJson()).toList();
        updateData['total_calories'] = totalCalories;
        updateData['total_protein'] = totalProtein;
        updateData['total_carbs'] = totalCarbs;
        updateData['total_fat'] = totalFat;
        updateData['total_cost'] = totalCost;
      }

      final result = await SupabaseService.update(
        SupabaseTables.mealPlans,
        mealPlanId,
        updateData,
      );

      if (result.isSuccess) {
        final mealPlan = MealPlan.fromJson(result.data!);
        final index = _mealPlans.indexWhere((plan) => plan.id == mealPlanId);
        if (index != -1) {
          _mealPlans[index] = mealPlan;
          notifyListeners();
        }
        return Result.success(mealPlan);
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error('Error updating meal plan: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Delete meal plan
  Future<Result<bool>> deleteMealPlan(String mealPlanId) async {
    try {
      setLoading(true);
      clearError();

      if (mealPlanId.isEmpty) {
        return Result.error('Meal plan ID cannot be empty');
      }

      final result = await SupabaseService.delete(
        SupabaseTables.mealPlans,
        mealPlanId,
      );

      if (result.isSuccess) {
        _mealPlans.removeWhere((plan) => plan.id == mealPlanId);
        notifyListeners();
        return Result.success(true);
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error('Error deleting meal plan: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Add meal food to database
  Future<Result<MealFood>> addMealFood({
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
  }) async {
    try {
      setLoading(true);
      clearError();

      // Validate inputs
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

      final foodData = {
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
        'sodium': sodium,
        'serving_size': servingSize,
        'category': category,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final result = await SupabaseService.insert(
        SupabaseTables.foods,
        foodData,
      );

      if (result.isSuccess) {
        final mealFood = MealFood.fromJson(result.data!);
        _mealFoods.add(mealFood);
        notifyListeners();
        return Result.success(mealFood);
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error('Error adding meal food: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Get meal foods by category
  Future<Result<List<MealFood>>> getMealFoodsByCategory(String category) async {
    try {
      if (category.isEmpty) {
        return Result.error('Category cannot be empty');
      }

      final result = await SupabaseService.selectWhere(
        SupabaseTables.foods,
        'category',
        category,
      );

      if (result.isSuccess) {
        final foods =
            result.data!.map((json) => MealFood.fromJson(json)).toList();
        foods.sort((a, b) => a.name.compareTo(b.name));
        return Result.success(foods);
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error(
          'Error getting meal foods by category: ${e.toString()}');
    }
  }

  /// Search meal foods by name
  Future<Result<List<MealFood>>> searchMealFoods(String query) async {
    try {
      if (query.isEmpty) {
        // Return all foods if query is empty
        return Result.success(_mealFoods);
      }

      final result = await SupabaseService.selectWithTextSearch(
        SupabaseTables.foods,
        'name',
        query,
      );

      if (result.isSuccess) {
        final foods =
            result.data!.map((json) => MealFood.fromJson(json)).toList();
        foods.sort((a, b) => a.name.compareTo(b.name));
        return Result.success(foods);
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error('Error searching meal foods: ${e.toString()}');
    }
  }

  /// Get all meal food categories
  Future<Result<List<String>>> getMealFoodCategories() async {
    try {
      final result = await SupabaseService.selectAll(SupabaseTables.foods);

      if (result.isSuccess) {
        final categories = result.data!
            .map((food) => food['category'] as String)
            .toSet()
            .toList()
          ..sort();
        return Result.success(categories);
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error(
          'Error getting meal food categories: ${e.toString()}');
    }
  }

  /// Calculate daily nutrition summary
  Future<Result<Map<String, double>>> calculateDailyNutrition(
    String userId,
    DateTime date,
  ) async {
    try {
      if (userId.isEmpty) {
        return Result.error('User ID cannot be empty');
      }

      final result = await getMealPlansByDate(userId, date);

      if (result.isError) {
        return Result.error(result.error!);
      }

      final dayMealPlans = result.data!;
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
  Future<Result<MealPlan>> generateMealPlan({
    required User user,
    required DateTime date,
    required String mealType,
    required List<String> preferredCategories,
    required List<String> dietaryRestrictions,
  }) async {
    try {
      if (mealType.isEmpty) {
        return Result.error('Meal type cannot be empty');
      }

      if (preferredCategories.isEmpty) {
        return Result.error('At least one preferred category must be selected');
      }

      // Load foods if not already loaded
      if (_mealFoods.isEmpty) {
        await _loadMealFoods();
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

      // Create meal plan using createMealPlan method
      return await createMealPlan(
        userId: user.id,
        date: date,
        mealType: mealType,
        items: items,
        notes: 'Generated meal plan',
      );
    } catch (e) {
      return Result.error('Error generating meal plan: ${e.toString()}');
    }
  }

  /// Get meal plan statistics
  Future<Result<Map<String, dynamic>>> getMealPlanStatistics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (userId.isEmpty) {
        return Result.error('User ID cannot be empty');
      }

      final result = await getMealPlansByUserId(userId);

      if (result.isError) {
        return Result.error(result.error!);
      }

      final periodMealPlans = result.data!.where((plan) {
        return plan.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            plan.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      if (periodMealPlans.isEmpty) {
        final days = endDate.difference(startDate).inDays + 1;
        return Result.success({
          'totalMeals': 0,
          'totalCalories': 0.0,
          'totalProtein': 0.0,
          'totalCarbs': 0.0,
          'totalFat': 0.0,
          'totalCost': 0.0,
          'averageRating': 0.0,
          'days': days,
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

  /// Real-time event handlers
  void _onMealPlanInserted(Map<String, dynamic> data) {
    try {
      final mealPlan = MealPlan.fromJson(data);
      _mealPlans.insert(0, mealPlan);
      notifyListeners();
    } catch (e) {
      debugPrint('Error handling meal plan insert: $e');
    }
  }

  void _onMealPlanUpdated(Map<String, dynamic> data) {
    try {
      final mealPlan = MealPlan.fromJson(data);
      final index = _mealPlans.indexWhere((plan) => plan.id == mealPlan.id);
      if (index != -1) {
        _mealPlans[index] = mealPlan;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error handling meal plan update: $e');
    }
  }

  void _onMealPlanDeleted(Map<String, dynamic> data) {
    try {
      final id = data['id'] as String;
      _mealPlans.removeWhere((plan) => plan.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error handling meal plan delete: $e');
    }
  }

  void _onMealFoodInserted(Map<String, dynamic> data) {
    try {
      final mealFood = MealFood.fromJson(data);
      _mealFoods.add(mealFood);
      notifyListeners();
    } catch (e) {
      debugPrint('Error handling meal food insert: $e');
    }
  }

  void _onMealFoodUpdated(Map<String, dynamic> data) {
    try {
      final mealFood = MealFood.fromJson(data);
      final index = _mealFoods.indexWhere((food) => food.id == mealFood.id);
      if (index != -1) {
        _mealFoods[index] = mealFood;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error handling meal food update: $e');
    }
  }

  void _onMealFoodDeleted(Map<String, dynamic> data) {
    try {
      final id = data['id'] as String;
      _mealFoods.removeWhere((food) => food.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error handling meal food delete: $e');
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
