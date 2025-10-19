import '../models/user.dart';
import '../models/meal_food.dart';

class MealGenerationService {
  // Generate a single meal for a specific meal type
  static Meal? generateSingleMeal(User user, String mealType) {
    final targetCalories = user.targetCalories;

    // Validate target calories
    if (targetCalories <= 0) {
      print('ERROR: Invalid target calories: $targetCalories');
      return null;
    }

    // Calculate calories for the specific meal type
    int mealCalories;
    switch (mealType) {
      case 'breakfast':
        mealCalories = (targetCalories * 0.25).round();
        break;
      case 'lunch':
        mealCalories = (targetCalories * 0.35).round();
        break;
      case 'dinner':
        mealCalories = (targetCalories * 0.30).round();
        break;
      case 'snack':
        mealCalories = (targetCalories * 0.10).round();
        break;
      default:
        mealCalories = (targetCalories * 0.25).round();
    }

    print('Generating single $mealType meal with $mealCalories calories');

    // Generate the meal based on type
    switch (mealType) {
      case 'breakfast':
        return _generateBreakfast(user, mealCalories);
      case 'lunch':
        return _generateLunch(user, mealCalories);
      case 'dinner':
        return _generateDinner(user, mealCalories);
      case 'snack':
        return _generateSnack(user, mealCalories);
      default:
        return _generateBreakfast(user, mealCalories);
    }
  }

  // Generate 4 meals based on user preferences and conditions
  static List<Meal> generatePersonalizedMeals(User user) {
    final meals = <Meal>[];
    final targetCalories = user.targetCalories;

    // Debug: Print user data to help identify issues
    print('Meal Generation Debug:');
    print('User: ${user.name}');
    print('Target Calories: $targetCalories');
    print('Goal: ${user.goal}');
    print('Activity Level: ${user.activityLevel}');
    print('BMR: ${user.bmr}');
    print('TDEE: ${user.tdee}');

    // Validate target calories
    if (targetCalories <= 0) {
      print('ERROR: Invalid target calories: $targetCalories');
      return meals; // Return empty list if invalid
    }

    // Distribute calories across 4 meals
    final breakfastCalories = (targetCalories * 0.25).round();
    final lunchCalories = (targetCalories * 0.35).round();
    final dinnerCalories = (targetCalories * 0.30).round();
    final snackCalories = (targetCalories * 0.10).round();

    print(
        'Meal calories - Breakfast: $breakfastCalories, Lunch: $lunchCalories, Dinner: $dinnerCalories, Snack: $snackCalories');

    // Generate breakfast
    meals.add(_generateBreakfast(user, breakfastCalories));

    // Generate lunch
    meals.add(_generateLunch(user, lunchCalories));

    // Generate dinner
    meals.add(_generateDinner(user, dinnerCalories));

    // Generate snack
    meals.add(_generateSnack(user, snackCalories));

    return meals;
  }

  static Meal _generateBreakfast(User user, int targetCalories) {
    final foods = <MealFood>[];

    // Base breakfast items based on preferences and restrictions
    if (user.foodPreferences.contains('vegetables')) {
      foods.add(MealFood(
        id: '1',
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
        imageUrl: '',
      ));
    } else {
      foods.add(MealFood(
        id: '2',
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
        imageUrl: '',
      ));
    }

    // Add fruit if no allergies
    if (!user.allergies.contains('citrus')) {
      foods.add(MealFood(
        id: '3',
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
        imageUrl: '',
      ));
    }

    // Add healthy fat
    foods.add(MealFood(
      id: '4',
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
      imageUrl: '',
    ));

    return Meal(
      id: 'breakfast_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Breakfast',
      foods: foods,
      totalCalories: foods.fold(0, (sum, food) => sum + food.calories),
      mealType: 'breakfast',
      createdAt: DateTime.now(),
    );
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

  // Adjust meals based on health conditions
  static List<Meal> adjustForHealthConditions(List<Meal> meals, User user) {
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
