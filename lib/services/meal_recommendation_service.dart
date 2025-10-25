import 'package:flutter/foundation.dart';
import '../models/food.dart';
import '../models/meal_plan.dart';
import '../models/user.dart';
import '../utils/health_calculations.dart';

class MealRecommendationService extends ChangeNotifier {
  List<Food> _foodDatabase = [];
  List<MealPlan> _userMealPlans = [];
  bool _isLoading = false;
  String? _error;

  List<Food> get foodDatabase => _foodDatabase;
  List<MealPlan> get userMealPlans => _userMealPlans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MealRecommendationService() {
    _initializeFoodDatabase();
  }

  // Add new food to database
  Future<void> addFood(Food food) async {
    _foodDatabase.add(food);
    notifyListeners();
  }

  // Remove food from database
  Future<void> removeFood(String foodId) async {
    _foodDatabase.removeWhere((food) => food.id == foodId);
    notifyListeners();
  }

  // Update existing food
  Future<void> updateFood(Food updatedFood) async {
    final index = _foodDatabase.indexWhere((food) => food.id == updatedFood.id);
    if (index != -1) {
      _foodDatabase[index] = updatedFood;
      notifyListeners();
    }
  }

  void _initializeFoodDatabase() {
    // Initialize with sample food data
    _foodDatabase = [
      // Proteins
      Food(
        id: '1',
        name: 'Grilled Chicken Breast',
        nameArabic: 'صدر دجاج مشوي',
        category: 'proteins',
        description: 'Lean protein source, perfect for muscle building',
        caloriesPer100g: 165,
        proteinPer100g: 31,
        carbsPer100g: 0,
        fatPer100g: 3.6,
        fiberPer100g: 0,
        sugarPer100g: 0,
        sodiumPer100g: 74,
        imageUrl: 'https://example.com/chicken.jpg',
        recipeInstructions:
            'Season with herbs and grill for 6-8 minutes per side',
        preparationTime: 20,
        servings: 1,
        tags: ['high-protein', 'low-carb', 'grilled'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Food(
        id: '2',
        name: 'Salmon Fillet',
        nameArabic: 'سمك السلمون',
        category: 'proteins',
        description: 'Rich in omega-3 fatty acids',
        caloriesPer100g: 208,
        proteinPer100g: 25,
        carbsPer100g: 0,
        fatPer100g: 12,
        fiberPer100g: 0,
        sugarPer100g: 0,
        sodiumPer100g: 44,
        imageUrl: 'https://example.com/salmon.jpg',
        recipeInstructions: 'Bake at 200°C for 12-15 minutes',
        preparationTime: 25,
        servings: 1,
        tags: ['omega-3', 'high-protein', 'baked'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Carbohydrates
      Food(
        id: '3',
        name: 'Brown Rice',
        nameArabic: 'أرز بني',
        category: 'carbohydrates',
        description: 'Whole grain rice with fiber',
        caloriesPer100g: 111,
        proteinPer100g: 2.6,
        carbsPer100g: 23,
        fatPer100g: 0.9,
        fiberPer100g: 1.8,
        sugarPer100g: 0.4,
        sodiumPer100g: 5,
        imageUrl: 'https://example.com/brown-rice.jpg',
        recipeInstructions: 'Cook 1:2 ratio rice to water for 45 minutes',
        preparationTime: 45,
        servings: 4,
        tags: ['whole-grain', 'fiber', 'complex-carb'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Vegetables
      Food(
        id: '4',
        name: 'Broccoli',
        nameArabic: 'بروكلي',
        category: 'vegetables',
        description: 'Nutrient-dense green vegetable',
        caloriesPer100g: 34,
        proteinPer100g: 2.8,
        carbsPer100g: 7,
        fatPer100g: 0.4,
        fiberPer100g: 2.6,
        sugarPer100g: 1.5,
        sodiumPer100g: 33,
        imageUrl: 'https://example.com/broccoli.jpg',
        recipeInstructions: 'Steam for 5-7 minutes until tender',
        preparationTime: 10,
        servings: 2,
        tags: ['vitamin-c', 'fiber', 'low-calorie'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Fruits
      Food(
        id: '5',
        name: 'Apple',
        nameArabic: 'تفاح',
        category: 'fruits',
        description: 'Sweet and crunchy fruit',
        caloriesPer100g: 52,
        proteinPer100g: 0.3,
        carbsPer100g: 14,
        fatPer100g: 0.2,
        fiberPer100g: 2.4,
        sugarPer100g: 10,
        sodiumPer100g: 1,
        imageUrl: 'https://example.com/apple.jpg',
        recipeInstructions: 'Wash and eat fresh',
        preparationTime: 1,
        servings: 1,
        tags: ['vitamin-c', 'fiber', 'antioxidants'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Content-based filtering using Nearest Neighbors algorithm
  List<Food> getRecommendedFoods(User user, String mealType) {
    if (_foodDatabase.isEmpty) return [];

    // Filter foods based on user preferences and restrictions
    List<Food> filteredFoods = _foodDatabase.where((food) {
      // Check for allergies
      for (String allergen in user.allergies) {
        if (food.containsAllergen(allergen)) return false;
      }

      // Check for health conditions
      if (user.healthConditions.contains('diabetes') && food.sugarPer100g > 10)
        return false;

      if (user.healthConditions.contains('hypertension') &&
          food.sodiumPer100g > 400) return false;

      return true;
    }).toList();

    // Calculate nutritional needs for the meal
    Map<String, double> mealMacros = _calculateMealMacros(user, mealType);

    // Score foods based on nutritional fit
    List<Map<String, dynamic>> scoredFoods = filteredFoods.map((food) {
      double score = _calculateFoodScore(food, mealMacros, user.goal);
      return {
        'food': food,
        'score': score,
      };
    }).toList();

    // Sort by score and return top recommendations
    scoredFoods.sort((a, b) => b['score'].compareTo(a['score']));

    return scoredFoods.take(10).map((item) => item['food'] as Food).toList();
  }

  Map<String, double> _calculateMealMacros(User user, String mealType) {
    double targetCalories = user.targetCalories;
    Map<String, double> macroDistribution =
        HealthCalculations.calculateMacroDistribution(
      targetCalories,
      user.goal,
    );

    // Distribute macros across meals
    double mealCalorieRatio;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        mealCalorieRatio = 0.25; // 25% of daily calories
        break;
      case 'lunch':
        mealCalorieRatio = 0.35; // 35% of daily calories
        break;
      case 'dinner':
        mealCalorieRatio = 0.30; // 30% of daily calories
        break;
      case 'snack':
        mealCalorieRatio = 0.10; // 10% of daily calories
        break;
      default:
        mealCalorieRatio = 0.25;
    }

    return {
      'calories': targetCalories * mealCalorieRatio,
      'protein': macroDistribution['protein']! * mealCalorieRatio,
      'carbs': macroDistribution['carbs']! * mealCalorieRatio,
      'fat': macroDistribution['fat']! * mealCalorieRatio,
    };
  }

  double _calculateFoodScore(
      Food food, Map<String, double> targetMacros, String goal) {
    double score = 0.0;

    // Base score from nutritional density
    score += food.proteinPer100g * 0.4; // Protein is important
    score += food.fiberPer100g * 0.3; // Fiber is beneficial
    score -= food.sugarPer100g * 0.2; // Sugar should be limited
    score -= food.sodiumPer100g * 0.001; // Sodium should be moderate

    // Adjust based on goal
    switch (goal.toLowerCase()) {
      case 'weight_loss':
        // Prefer lower calorie, higher protein foods
        score += (food.proteinPer100g / food.caloriesPer100g) * 10;
        break;
      case 'weight_gain':
        // Prefer higher calorie foods
        score += food.caloriesPer100g * 0.01;
        break;
      case 'maintenance':
        // Balanced approach
        score += 1.0;
        break;
    }

    return score;
  }

  // Generate complete meal plan for a day
  Future<List<MealPlan>> generateDailyMealPlan(User user, DateTime date) async {
    _setLoading(true);
    _clearError();

    try {
      List<MealPlan> dailyMealPlan = [];

      // Generate meals for each meal type
      for (String mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
        List<Food> recommendedFoods = getRecommendedFoods(user, mealType);

        if (recommendedFoods.isNotEmpty) {
          // Create meal plan with recommended foods
          MealPlan mealPlan =
              _createMealPlan(user, mealType, recommendedFoods, date);
          dailyMealPlan.add(mealPlan);
        }
      }

      _setLoading(false);
      return dailyMealPlan;
    } catch (e) {
      _setError('Failed to generate meal plan: $e');
      _setLoading(false);
      return [];
    }
  }

  MealPlan _createMealPlan(
      User user, String mealType, List<Food> foods, DateTime date) {
    List<MealItem> mealItems = [];
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalCost = 0;

    // Create meal items with appropriate portions
    for (Food food in foods.take(3)) {
      // Limit to 3 items per meal
      double portionSize = _calculatePortionSize(food, user, mealType);

      Map<String, double> nutrition = food.getNutritionForServing(portionSize);

      MealItem item = MealItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        foodId: food.id,
        foodName: food.name,
        quantity: portionSize,
        calories: nutrition['calories']!,
        protein: nutrition['protein']!,
        carbs: nutrition['carbs']!,
        fat: nutrition['fat']!,
        cost: _estimateFoodCost(food, portionSize),
      );

      mealItems.add(item);

      totalCalories += item.calories;
      totalProtein += item.protein;
      totalCarbs += item.carbs;
      totalFat += item.fat;
      totalCost += item.cost;
    }

    return MealPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      date: date,
      mealType: mealType,
      items: mealItems,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      totalCost: totalCost,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  double _calculatePortionSize(Food food, User user, String mealType) {
    // Calculate portion size based on user's caloric needs and meal type
    Map<String, double> mealMacros = _calculateMealMacros(user, mealType);

    // Estimate portion size to meet caloric needs
    double targetCalories = mealMacros['calories']!;
    double portionSize = (targetCalories / food.caloriesPer100g) * 100;

    // Limit portion size to reasonable amounts
    return portionSize.clamp(50, 300); // Between 50g and 300g
  }

  double _estimateFoodCost(Food food, double portionSize) {
    // Mock cost estimation - replace with actual price data
    double baseCostPer100g = 2.0; // SAR per 100g
    return (portionSize / 100) * baseCostPer100g;
  }

  // Search foods by name or category
  List<Food> searchFoods(String query) {
    if (query.isEmpty) return _foodDatabase;

    return _foodDatabase.where((food) {
      return food.name.toLowerCase().contains(query.toLowerCase()) ||
          food.nameArabic.contains(query) ||
          food.category.toLowerCase().contains(query.toLowerCase()) ||
          food.tags
              .any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  // Get foods by category
  List<Food> getFoodsByCategory(String category) {
    return _foodDatabase.where((food) => food.category == category).toList();
  }

  // Delete food from database
  void deleteFood(String foodId) {
    _foodDatabase.removeWhere((food) => food.id == foodId);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
