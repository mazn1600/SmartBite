/// User Progress model
///
/// Represents daily health and fitness progress tracking
class UserProgress {
  final String id;
  final String userId;
  final DateTime date;
  final double? weight; // in kg
  final double? bodyFatPercentage;
  final double? muscleMass; // in kg
  final double? waterIntake; // in liters
  final double? caloriesConsumed;
  final double? caloriesBurned;
  final int steps;
  final double? sleepHours;
  final int? moodRating; // 1-10
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProgress({
    required this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.bodyFatPercentage,
    this.muscleMass,
    this.waterIntake,
    this.caloriesConsumed,
    this.caloriesBurned,
    this.steps = 0,
    this.sleepHours,
    this.moodRating,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // Date only (YYYY-MM-DD)
      'weight': weight,
      'body_fat_percentage': bodyFatPercentage,
      'muscle_mass': muscleMass,
      'water_intake': waterIntake,
      'calories_consumed': caloriesConsumed,
      'calories_burned': caloriesBurned,
      'steps': steps,
      'sleep_hours': sleepHours,
      'mood_rating': moodRating,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] ?? json['id'],
      userId: json['user_id'] ?? json['userId'],
      date: json['date'] != null
          ? (json['date'] is DateTime
              ? json['date']
              : DateTime.parse(json['date']))
          : DateTime.now(),
      weight: json['weight'] != null
          ? (json['weight'] is double
              ? json['weight']
              : (json['weight'] as num).toDouble())
          : null,
      bodyFatPercentage: json['body_fat_percentage'] != null
          ? (json['body_fat_percentage'] is double
              ? json['body_fat_percentage']
              : (json['body_fat_percentage'] as num).toDouble())
          : null,
      muscleMass: json['muscle_mass'] != null
          ? (json['muscle_mass'] is double
              ? json['muscle_mass']
              : (json['muscle_mass'] as num).toDouble())
          : null,
      waterIntake: json['water_intake'] != null
          ? (json['water_intake'] is double
              ? json['water_intake']
              : (json['water_intake'] as num).toDouble())
          : null,
      caloriesConsumed: json['calories_consumed'] != null
          ? (json['calories_consumed'] is double
              ? json['calories_consumed']
              : (json['calories_consumed'] as num).toDouble())
          : null,
      caloriesBurned: json['calories_burned'] != null
          ? (json['calories_burned'] is double
              ? json['calories_burned']
              : (json['calories_burned'] as num).toDouble())
          : null,
      steps: json['steps'] is int
          ? json['steps']
          : (json['steps'] as num?)?.toInt() ?? 0,
      sleepHours: json['sleep_hours'] != null
          ? (json['sleep_hours'] is double
              ? json['sleep_hours']
              : (json['sleep_hours'] as num).toDouble())
          : null,
      moodRating: json['mood_rating'] is int
          ? json['mood_rating']
          : json['mood_rating'] != null
              ? (json['mood_rating'] as num).toInt()
              : null,
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress.fromJson(map);
  }

  UserProgress copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? weight,
    double? bodyFatPercentage,
    double? muscleMass,
    double? waterIntake,
    double? caloriesConsumed,
    double? caloriesBurned,
    int? steps,
    double? sleepHours,
    int? moodRating,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMass: muscleMass ?? this.muscleMass,
      waterIntake: waterIntake ?? this.waterIntake,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      steps: steps ?? this.steps,
      sleepHours: sleepHours ?? this.sleepHours,
      moodRating: moodRating ?? this.moodRating,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

