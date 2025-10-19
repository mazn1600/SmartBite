class User {
  final String id;
  final String email;
  final String name;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final double? targetWeight; // in kg - optional
  final String gender;
  final String activityLevel;
  final String goal; // weight_loss, weight_gain, maintenance
  final List<String> allergies;
  final List<String> healthConditions;
  final List<String> foodPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    this.targetWeight,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    this.allergies = const [],
    this.healthConditions = const [],
    this.foodPreferences = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Calculate BMR using Mifflin-St Jeor Equation
  double get bmr {
    if (gender.toLowerCase() == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  double get tdee {
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
  double get targetCalories {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'gender': gender,
      'activityLevel': activityLevel,
      'goal': goal,
      'allergies': allergies,
      'healthConditions': healthConditions,
      'foodPreferences': foodPreferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      age: json['age'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      targetWeight: json['targetWeight']?.toDouble(),
      gender: json['gender'],
      activityLevel: json['activityLevel'],
      goal: json['goal'],
      allergies: List<String>.from(json['allergies'] ?? []),
      healthConditions: List<String>.from(json['healthConditions'] ?? []),
      foodPreferences: List<String>.from(json['foodPreferences'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    int? age,
    double? height,
    double? weight,
    double? targetWeight,
    String? gender,
    String? activityLevel,
    String? goal,
    List<String>? allergies,
    List<String>? healthConditions,
    List<String>? foodPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      allergies: allergies ?? this.allergies,
      healthConditions: healthConditions ?? this.healthConditions,
      foodPreferences: foodPreferences ?? this.foodPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
