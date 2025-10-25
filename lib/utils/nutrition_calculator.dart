import '../models/user.dart';
import '../constants/app_constants.dart';

/// Utility class for calculating nutrition and health metrics
class NutritionCalculator {
  /// Calculate BMI (Body Mass Index)
  static double calculateBMI(double weightKg, double heightCm) {
    if (weightKg <= 0 || heightCm <= 0) {
      throw ArgumentError('Weight and height must be greater than 0');
    }

    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal weight';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) {
      throw ArgumentError('Weight, height, and age must be greater than 0');
    }

    if (!AppConstants.genders.contains(gender)) {
      throw ArgumentError(
          'Invalid gender. Must be one of: ${AppConstants.genders.join(', ')}');
    }

    // Mifflin-St Jeor Equation
    if (gender.toLowerCase() == 'male') {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    if (bmr <= 0) {
      throw ArgumentError('BMR must be greater than 0');
    }

    if (!AppConstants.activityLevels.contains(activityLevel)) {
      throw ArgumentError(
          'Invalid activity level. Must be one of: ${AppConstants.activityLevels.join(', ')}');
    }

    // Activity level multipliers
    final activityMultipliers = {
      'sedentary': 1.2,
      'lightly_active': 1.375,
      'moderately_active': 1.55,
      'very_active': 1.725,
      'extremely_active': 1.9,
    };

    final activityMultiplier = activityMultipliers[activityLevel]!;
    return bmr * activityMultiplier;
  }

  /// Calculate ideal weight range based on height
  static Map<String, double> calculateIdealWeightRange(double heightCm) {
    if (heightCm <= 0) {
      throw ArgumentError('Height must be greater than 0');
    }

    final heightM = heightCm / 100;
    final lowerWeight = 18.5 * (heightM * heightM);
    final upperWeight = 24.9 * (heightM * heightM);

    return {
      'min': lowerWeight,
      'max': upperWeight,
    };
  }

  /// Calculate daily calorie needs based on goal
  static double calculateDailyCalorieNeeds({
    required double tdee,
    required String goal,
  }) {
    if (tdee <= 0) {
      throw ArgumentError('TDEE must be greater than 0');
    }

    if (!AppConstants.goals.contains(goal)) {
      throw ArgumentError(
          'Invalid goal. Must be one of: ${AppConstants.goals.join(', ')}');
    }

    // Goal multipliers
    final goalMultipliers = {
      'weight_loss': 0.8, // 20% calorie deficit
      'weight_gain': 1.2, // 20% calorie surplus
      'maintenance': 1.0, // No change
    };

    final goalMultiplier = goalMultipliers[goal]!;
    return tdee * goalMultiplier;
  }

  /// Calculate macronutrient distribution
  static Map<String, double> calculateMacroDistribution({
    required double calories,
    required String goal,
  }) {
    if (calories <= 0) {
      throw ArgumentError('Calories must be greater than 0');
    }

    double proteinPercentage;
    double carbsPercentage;
    double fatPercentage;

    switch (goal.toLowerCase()) {
      case 'weight_loss':
        proteinPercentage = 0.30; // 30% protein
        carbsPercentage = 0.40; // 40% carbs
        fatPercentage = 0.30; // 30% fat
        break;
      case 'muscle_gain':
        proteinPercentage = 0.25; // 25% protein
        carbsPercentage = 0.50; // 50% carbs
        fatPercentage = 0.25; // 25% fat
        break;
      case 'maintenance':
      default:
        proteinPercentage = 0.20; // 20% protein
        carbsPercentage = 0.50; // 50% carbs
        fatPercentage = 0.30; // 30% fat
        break;
    }

    return {
      'protein': calories * proteinPercentage / 4, // 4 calories per gram
      'carbs': calories * carbsPercentage / 4, // 4 calories per gram
      'fat': calories * fatPercentage / 9, // 9 calories per gram
    };
  }

  /// Calculate water intake recommendation
  static double calculateWaterIntake({
    required double weightKg,
    required String activityLevel,
    required String climate,
  }) {
    if (weightKg <= 0) {
      throw ArgumentError('Weight must be greater than 0');
    }

    // Base water intake: 35ml per kg of body weight
    double baseWaterIntake = weightKg * 35;

    // Adjust for activity level
    double activityMultiplier = 1.0;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        activityMultiplier = 1.0;
        break;
      case 'lightly_active':
        activityMultiplier = 1.2;
        break;
      case 'moderately_active':
        activityMultiplier = 1.4;
        break;
      case 'very_active':
        activityMultiplier = 1.6;
        break;
      case 'extremely_active':
        activityMultiplier = 1.8;
        break;
    }

    // Adjust for climate
    double climateMultiplier = 1.0;
    switch (climate.toLowerCase()) {
      case 'hot':
        climateMultiplier = 1.3;
        break;
      case 'moderate':
        climateMultiplier = 1.0;
        break;
      case 'cold':
        climateMultiplier = 0.9;
        break;
    }

    return baseWaterIntake * activityMultiplier * climateMultiplier;
  }

  /// Calculate meal calorie distribution
  static Map<String, double> calculateMealCalorieDistribution({
    required double dailyCalories,
    required List<String> mealTypes,
  }) {
    if (dailyCalories <= 0) {
      throw ArgumentError('Daily calories must be greater than 0');
    }

    if (mealTypes.isEmpty) {
      throw ArgumentError('At least one meal type must be provided');
    }

    final mealDistribution = <String, double>{};
    final totalMeals = mealTypes.length;

    // Distribute calories evenly across meals
    final caloriesPerMeal = dailyCalories / totalMeals;

    for (final mealType in mealTypes) {
      mealDistribution[mealType] = caloriesPerMeal;
    }

    return mealDistribution;
  }

  /// Calculate portion size based on calories
  static double calculatePortionSize({
    required double foodCaloriesPer100g,
    required double targetCalories,
  }) {
    if (foodCaloriesPer100g <= 0) {
      throw ArgumentError('Food calories per 100g must be greater than 0');
    }

    if (targetCalories <= 0) {
      throw ArgumentError('Target calories must be greater than 0');
    }

    return (targetCalories / foodCaloriesPer100g) * 100;
  }

  /// Calculate nutrition density score
  static double calculateNutritionDensityScore({
    required double calories,
    required double protein,
    required double fiber,
    required double vitamins,
    required double minerals,
  }) {
    if (calories <= 0) {
      throw ArgumentError('Calories must be greater than 0');
    }

    // Nutrition density = (protein + fiber + vitamins + minerals) / calories
    final totalNutrients = protein + fiber + vitamins + minerals;
    return totalNutrients / calories;
  }

  /// Calculate meal timing recommendations
  static Map<String, String> calculateMealTimingRecommendations({
    required String wakeUpTime,
    required String sleepTime,
    required List<String> mealTypes,
  }) {
    if (wakeUpTime.isEmpty || sleepTime.isEmpty) {
      throw ArgumentError('Wake up time and sleep time cannot be empty');
    }

    if (mealTypes.isEmpty) {
      throw ArgumentError('At least one meal type must be provided');
    }

    final mealTimings = <String, String>{};
    final totalMeals = mealTypes.length;

    // Parse times (assuming 24-hour format)
    final wakeUp = _parseTime(wakeUpTime);
    final sleep = _parseTime(sleepTime);

    // Calculate time between wake up and sleep
    final totalHours = sleep.difference(wakeUp).inHours;
    final intervalHours = totalHours / (totalMeals + 1);

    for (int i = 0; i < totalMeals; i++) {
      final mealTime =
          wakeUp.add(Duration(hours: (intervalHours * (i + 1)).round()));
      mealTimings[mealTypes[i]] = _formatTime(mealTime);
    }

    return mealTimings;
  }

  /// Calculate supplement recommendations based on deficiencies
  static List<String> calculateSupplementRecommendations({
    required Map<String, double> currentIntake,
    required Map<String, double> recommendedIntake,
  }) {
    final recommendations = <String>[];

    for (final nutrient in recommendedIntake.keys) {
      final current = currentIntake[nutrient] ?? 0.0;
      final recommended = recommendedIntake[nutrient]!;

      if (current < recommended * 0.8) {
        // 80% of recommended
        recommendations.add(nutrient);
      }
    }

    return recommendations;
  }

  /// Calculate body fat percentage (rough estimate)
  static double calculateBodyFatPercentage({
    required double bmi,
    required int age,
    required String gender,
  }) {
    if (bmi <= 0 || age <= 0) {
      throw ArgumentError('BMI and age must be greater than 0');
    }

    if (!AppConstants.genders.contains(gender)) {
      throw ArgumentError(
          'Invalid gender. Must be one of: ${AppConstants.genders.join(', ')}');
    }

    // Deurenberg formula
    if (gender.toLowerCase() == 'male') {
      return (1.20 * bmi) + (0.23 * age) - 16.2;
    } else {
      return (1.20 * bmi) + (0.23 * age) - 5.4;
    }
  }

  /// Calculate metabolic age
  static int calculateMetabolicAge({
    required double bmr,
    required int chronologicalAge,
    required String gender,
  }) {
    if (bmr <= 0 || chronologicalAge <= 0) {
      throw ArgumentError('BMR and chronological age must be greater than 0');
    }

    // Average BMR for age and gender (simplified)
    double averageBMR;
    if (gender.toLowerCase() == 'male') {
      averageBMR = 1500 + (chronologicalAge * -5); // Decreases with age
    } else {
      averageBMR = 1200 + (chronologicalAge * -4); // Decreases with age
    }

    // Calculate metabolic age based on BMR comparison
    final metabolicAge = chronologicalAge + ((averageBMR - bmr) / 10);
    return metabolicAge.round().clamp(18, 80);
  }

  /// Helper method to parse time string
  static DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Helper method to format time
  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Calculate complete user health profile
  static Map<String, dynamic> calculateUserHealthProfile(User user) {
    try {
      final bmi = calculateBMI(user.weight, user.height);
      final bmr = calculateBMR(
        weightKg: user.weight,
        heightCm: user.height,
        age: user.age,
        gender: user.gender,
      );
      final tdee = calculateTDEE(
        bmr: bmr,
        activityLevel: user.activityLevel,
      );
      final idealWeight = calculateIdealWeightRange(user.height);
      final dailyCalories = calculateDailyCalorieNeeds(
        tdee: tdee,
        goal: user.goal,
      );
      final macros = calculateMacroDistribution(
        calories: dailyCalories,
        goal: user.goal,
      );
      final waterIntake = calculateWaterIntake(
        weightKg: user.weight,
        activityLevel: user.activityLevel,
        climate: 'moderate', // Default to moderate climate
      );
      final bodyFatPercentage = calculateBodyFatPercentage(
        bmi: bmi,
        age: user.age,
        gender: user.gender,
      );
      final metabolicAge = calculateMetabolicAge(
        bmr: bmr,
        chronologicalAge: user.age,
        gender: user.gender,
      );

      return {
        'bmi': bmi,
        'bmiCategory': getBMICategory(bmi),
        'bmr': bmr,
        'tdee': tdee,
        'idealWeight': idealWeight,
        'dailyCalories': dailyCalories,
        'macros': macros,
        'waterIntake': waterIntake,
        'bodyFatPercentage': bodyFatPercentage,
        'metabolicAge': metabolicAge,
        'isHealthy': bmi >= 18.5 && bmi < 25,
        'recommendations': _generateHealthRecommendations(
          bmi: bmi,
          bodyFatPercentage: bodyFatPercentage,
          metabolicAge: metabolicAge,
          chronologicalAge: user.age,
        ),
      };
    } catch (e) {
      throw Exception('Error calculating user health profile: ${e.toString()}');
    }
  }

  /// Generate health recommendations based on calculated metrics
  static List<String> _generateHealthRecommendations({
    required double bmi,
    required double bodyFatPercentage,
    required int metabolicAge,
    required int chronologicalAge,
  }) {
    final recommendations = <String>[];

    // BMI recommendations
    if (bmi < 18.5) {
      recommendations
          .add('Consider increasing caloric intake to reach a healthy weight');
    } else if (bmi >= 25) {
      recommendations.add(
          'Consider reducing caloric intake and increasing physical activity');
    }

    // Body fat recommendations
    if (bodyFatPercentage > 25) {
      recommendations
          .add('Focus on strength training to reduce body fat percentage');
    }

    // Metabolic age recommendations
    if (metabolicAge > chronologicalAge + 5) {
      recommendations.add(
          'Improve metabolic health through regular exercise and balanced nutrition');
    }

    // General recommendations
    recommendations.add(
        'Maintain a balanced diet with adequate protein, carbs, and healthy fats');
    recommendations
        .add('Stay hydrated by drinking enough water throughout the day');
    recommendations.add('Get regular exercise and adequate sleep');

    return recommendations;
  }
}
