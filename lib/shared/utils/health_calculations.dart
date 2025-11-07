/// Health calculation utilities
class HealthCalculations {
  // Calculate BMI (Body Mass Index)
  static double calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  // Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'underweight';
    if (bmi >= 18.5 && bmi < 25) return 'normal';
    if (bmi >= 25 && bmi < 30) return 'overweight';
    return 'obese';
  }

  // Calculate BMR using Mifflin-St Jeor Equation
  static double calculateBMR({
    required double weight,
    required double height,
    required int age,
    required String gender,
  }) {
    if (gender.toLowerCase() == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  static double calculateTDEE(double bmr, String activityLevel) {
    double activityMultiplier;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'lightly_active':
        activityMultiplier = 1.375;
        break;
      case 'moderately_active':
        activityMultiplier = 1.55;
        break;
      case 'very_active':
        activityMultiplier = 1.725;
        break;
      case 'extremely_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2;
    }
    return bmr * activityMultiplier;
  }

  // Calculate target calories based on goal
  static double calculateTargetCalories(double tdee, String goal) {
    switch (goal.toLowerCase()) {
      case 'weight_loss':
        return tdee - 500; // 500 calorie deficit
      case 'weight_gain':
        return tdee + 500; // 500 calorie surplus
      case 'maintenance':
      default:
        return tdee;
    }
  }

  // Calculate macronutrient distribution
  static Map<String, double> calculateMacroDistribution(
    double targetCalories,
    String goal,
  ) {
    double proteinPercentage;
    double carbPercentage;
    double fatPercentage;

    switch (goal.toLowerCase()) {
      case 'weight_loss':
        proteinPercentage = 30;
        carbPercentage = 40;
        fatPercentage = 30;
        break;
      case 'weight_gain':
        proteinPercentage = 25;
        carbPercentage = 50;
        fatPercentage = 25;
        break;
      case 'maintenance':
      default:
        proteinPercentage = 25;
        carbPercentage = 45;
        fatPercentage = 30;
        break;
    }

    return {
      'protein': (targetCalories * proteinPercentage / 100) / 4, // 4 cal/g
      'carbs': (targetCalories * carbPercentage / 100) / 4, // 4 cal/g
      'fat': (targetCalories * fatPercentage / 100) / 9, // 9 cal/g
    };
  }

  // Calculate ideal weight range
  static Map<String, double> calculateIdealWeightRange(
      double height, String gender) {
    double lowerBound, upperBound;

    if (gender.toLowerCase() == 'male') {
      lowerBound = 18.5 * ((height / 100) * (height / 100));
      upperBound = 24.9 * ((height / 100) * (height / 100));
    } else {
      lowerBound = 18.5 * ((height / 100) * (height / 100));
      upperBound = 24.9 * ((height / 100) * (height / 100));
    }

    return {
      'min': lowerBound,
      'max': upperBound,
    };
  }

  // Calculate weight change timeline
  static Map<String, dynamic> calculateWeightChangeTimeline({
    required double currentWeight,
    required double targetWeight,
    required String goal,
  }) {
    double weightDifference = targetWeight - currentWeight;
    double weeklyChange;
    int weeksToGoal = 0;

    switch (goal.toLowerCase()) {
      case 'weight_loss':
        weeklyChange = 0.5; // 0.5 kg per week
        break;
      case 'weight_gain':
        weeklyChange = 0.5; // 0.5 kg per week
        break;
      case 'maintenance':
      default:
        weeklyChange = 0;
        weeksToGoal = 0;
        break;
    }

    if (goal.toLowerCase() != 'maintenance') {
      weeksToGoal = (weightDifference.abs() / weeklyChange).ceil();
    }

    return {
      'weightDifference': weightDifference,
      'weeklyChange': weeklyChange,
      'weeksToGoal': weeksToGoal,
      'isRealistic': weeksToGoal <= 52, // Max 1 year
    };
  }

  // Calculate water intake recommendation
  static double calculateWaterIntake({
    required double weight,
    required String activityLevel,
    required String gender,
  }) {
    double baseWater = weight * 35; // 35ml per kg

    // Adjust for activity level
    double activityMultiplier;
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
      default:
        activityMultiplier = 1.0;
    }

    // Adjust for gender (men typically need more)
    if (gender.toLowerCase() == 'male') {
      activityMultiplier *= 1.1;
    }

    return baseWater * activityMultiplier;
  }

  // Validate health metrics
  static Map<String, String> validateHealthMetrics({
    required double weight,
    required double height,
    required int age,
    required String gender,
  }) {
    Map<String, String> errors = {};

    if (weight < 20 || weight > 300) {
      errors['weight'] = 'Weight must be between 20 and 300 kg';
    }

    if (height < 100 || height > 250) {
      errors['height'] = 'Height must be between 100 and 250 cm';
    }

    if (age < 13 || age > 120) {
      errors['age'] = 'Age must be between 13 and 120 years';
    }

    if (!['male', 'female'].contains(gender.toLowerCase())) {
      errors['gender'] = 'Gender must be male or female';
    }

    return errors;
  }

  // Get health recommendations based on BMI
  static List<String> getHealthRecommendations(double bmi) {
    List<String> recommendations = [];

    if (bmi < 18.5) {
      recommendations.addAll([
        'Consider consulting a healthcare provider',
        'Focus on nutrient-dense foods',
        'Consider gradual weight gain',
        'Ensure adequate protein intake',
      ]);
    } else if (bmi >= 18.5 && bmi < 25) {
      recommendations.addAll([
        'Maintain current healthy habits',
        'Focus on balanced nutrition',
        'Stay physically active',
        'Monitor portion sizes',
      ]);
    } else if (bmi >= 25 && bmi < 30) {
      recommendations.addAll([
        'Consider gradual weight loss',
        'Increase physical activity',
        'Focus on portion control',
        'Choose nutrient-dense foods',
      ]);
    } else {
      recommendations.addAll([
        'Consult a healthcare provider',
        'Consider professional weight management',
        'Focus on sustainable lifestyle changes',
        'Prioritize health over rapid weight loss',
      ]);
    }

    return recommendations;
  }
}
