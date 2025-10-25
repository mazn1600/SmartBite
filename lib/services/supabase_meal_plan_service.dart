import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../services/supabase_service.dart';
import '../models/meal_plan.dart';
import '../models/meal_food.dart';
import '../utils/error_handler.dart';

/// Supabase-based meal plan service
class SupabaseMealPlanService extends ChangeNotifier {
  List<MealPlan> _mealPlans = [];
  List<MealFood> _mealFoods = [];
  bool _isLoading = false;
  String? _error;

  List<MealPlan> get mealPlans => _mealPlans;
  List<MealFood> get mealFoods => _mealFoods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SupabaseMealPlanService() {
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
    required DateTime date,
    required String mealType,
    required List<MealItem> items,
    String? notes,
    double rating = 0.0,
  }) async {
    if (SupabaseConfig.userId == null) {
      return Result.error('User not authenticated');
    }

    try {
      setLoading(true);
      clearError();

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

      final mealPlanData = {
        'user_id': SupabaseConfig.userId,
        'date': date.toIso8601String(),
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
      final result = await SupabaseService.selectWhere(
        SupabaseTables.mealPlans,
        'user_id',
        userId,
      );

      if (result.isSuccess) {
        final mealPlans =
            result.data!.map((json) => MealPlan.fromJson(json)).toList();
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
      final startOfDay = DateTime(date.year, date.month, date.day);

      final result = await SupabaseService.selectWhere(
        SupabaseTables.mealPlans,
        'user_id',
        userId,
      );

      if (result.isSuccess) {
        final mealPlans =
            result.data!.map((json) => MealPlan.fromJson(json)).where((plan) {
          final planDate =
              DateTime.parse(plan.date.toIso8601String().split('T')[0]);
          return planDate.isAtSameMomentAs(startOfDay);
        }).toList();
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

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (date != null) updateData['date'] = date.toIso8601String();
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

  /// Search meal foods
  Future<Result<List<MealFood>>> searchMealFoods(String query) async {
    try {
      if (query.isEmpty) {
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
        return Result.success(foods);
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error('Error searching meal foods: ${e.toString()}');
    }
  }

  /// Get meal foods by category
  Future<Result<List<MealFood>>> getMealFoodsByCategory(String category) async {
    try {
      final result = await SupabaseService.selectWhere(
        SupabaseTables.foods,
        'category',
        category,
      );

      if (result.isSuccess) {
        final foods =
            result.data!.map((json) => MealFood.fromJson(json)).toList();
        return Result.success(foods);
      } else {
        return Result.error(result.error!);
      }
    } catch (e) {
      return Result.error(
          'Error getting meal foods by category: ${e.toString()}');
    }
  }

  /// Get all meal food categories
  Future<Result<List<String>>> getMealFoodCategories() async {
    try {
      // Get all foods and extract unique categories
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

  /// Real-time event handlers
  void _onMealPlanInserted(Map<String, dynamic> data) {
    final mealPlan = MealPlan.fromJson(data);
    _mealPlans.insert(0, mealPlan);
    notifyListeners();
  }

  void _onMealPlanUpdated(Map<String, dynamic> data) {
    final mealPlan = MealPlan.fromJson(data);
    final index = _mealPlans.indexWhere((plan) => plan.id == mealPlan.id);
    if (index != -1) {
      _mealPlans[index] = mealPlan;
      notifyListeners();
    }
  }

  void _onMealPlanDeleted(Map<String, dynamic> data) {
    final id = data['id'] as String;
    _mealPlans.removeWhere((plan) => plan.id == id);
    notifyListeners();
  }

  void _onMealFoodInserted(Map<String, dynamic> data) {
    final mealFood = MealFood.fromJson(data);
    _mealFoods.add(mealFood);
    notifyListeners();
  }

  void _onMealFoodUpdated(Map<String, dynamic> data) {
    final mealFood = MealFood.fromJson(data);
    final index = _mealFoods.indexWhere((food) => food.id == mealFood.id);
    if (index != -1) {
      _mealFoods[index] = mealFood;
      notifyListeners();
    }
  }

  void _onMealFoodDeleted(Map<String, dynamic> data) {
    final id = data['id'] as String;
    _mealFoods.removeWhere((food) => food.id == id);
    notifyListeners();
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
