import '../constants/app_constants.dart';

/// Comprehensive validation utilities for SmartBite app
class Validators {
  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must be less than ${AppConstants.maxPasswordLength} characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validates password confirmation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates name
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validates age
  static String? age(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }

    if (age < AppConstants.minAge || age > AppConstants.maxAge) {
      return 'Age must be between ${AppConstants.minAge} and ${AppConstants.maxAge}';
    }

    return null;
  }

  /// Validates height
  static String? height(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }

    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid height';
    }

    if (height < AppConstants.minHeight || height > AppConstants.maxHeight) {
      return 'Height must be between ${AppConstants.minHeight} and ${AppConstants.maxHeight} cm';
    }

    return null;
  }

  /// Validates weight
  static String? weight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid weight';
    }

    if (weight < AppConstants.minWeight || weight > AppConstants.maxWeight) {
      return 'Weight must be between ${AppConstants.minWeight} and ${AppConstants.maxWeight} kg';
    }

    return null;
  }

  /// Validates target weight
  static String? targetWeight(String? value, double currentWeight) {
    if (value == null || value.isEmpty) {
      return null; // Target weight is optional
    }

    final targetWeight = double.tryParse(value);
    if (targetWeight == null) {
      return 'Please enter a valid target weight';
    }

    if (targetWeight < AppConstants.minWeight ||
        targetWeight > AppConstants.maxWeight) {
      return 'Target weight must be between ${AppConstants.minWeight} and ${AppConstants.maxWeight} kg';
    }

    // Check if target weight is reasonable compared to current weight
    final weightDifference = (targetWeight - currentWeight).abs();
    if (weightDifference > 50) {
      return 'Target weight seems unrealistic. Please check your input.';
    }

    return null;
  }

  /// Validates gender selection
  static String? gender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your gender';
    }

    if (!AppConstants.genders.contains(value.toLowerCase())) {
      return 'Please select a valid gender';
    }

    return null;
  }

  /// Validates activity level selection
  static String? activityLevel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your activity level';
    }

    if (!AppConstants.activityLevels.contains(value.toLowerCase())) {
      return 'Please select a valid activity level';
    }

    return null;
  }

  /// Validates goal selection
  static String? goal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your goal';
    }

    if (!AppConstants.goals.contains(value.toLowerCase())) {
      return 'Please select a valid goal';
    }

    return null;
  }

  /// Validates food category selection
  static String? foodCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a food category';
    }

    if (!AppConstants.foodCategories.contains(value.toLowerCase())) {
      return 'Please select a valid food category';
    }

    return null;
  }

  /// Validates dietary preference selection
  static String? dietaryPreference(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Dietary preferences are optional
    }

    if (!AppConstants.dietaryPreferences.contains(value.toLowerCase())) {
      return 'Please select a valid dietary preference';
    }

    return null;
  }

  /// Validates allergen selection
  static String? allergen(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allergens are optional
    }

    if (!AppConstants.commonAllergens.contains(value.toLowerCase())) {
      return 'Please select a valid allergen';
    }

    return null;
  }

  /// Validates health condition selection
  static String? healthCondition(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Health conditions are optional
    }

    if (!AppConstants.healthConditions.contains(value.toLowerCase())) {
      return 'Please select a valid health condition';
    }

    return null;
  }

  /// Validates serving size
  static String? servingSize(String? value) {
    if (value == null || value.isEmpty) {
      return 'Serving size is required';
    }

    final servingSize = double.tryParse(value);
    if (servingSize == null) {
      return 'Please enter a valid serving size';
    }

    if (servingSize <= 0) {
      return 'Serving size must be greater than 0';
    }

    if (servingSize > 1000) {
      return 'Serving size seems too large. Please check your input.';
    }

    return null;
  }

  /// Validates phone number (Saudi format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid Saudi phone number
    if (digitsOnly.length == 10 && digitsOnly.startsWith('5')) {
      return null;
    }

    if (digitsOnly.length == 13 && digitsOnly.startsWith('9665')) {
      return null;
    }

    return 'Please enter a valid Saudi phone number (e.g., 5xxxxxxxxx)';
  }

  /// Validates required field
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates non-empty list
  static String? requiredList(List<dynamic>? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please select at least one $fieldName';
    }
    return null;
  }

  /// Validates positive number
  static String? positiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid $fieldName';
    }

    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }

  /// Validates integer
  static String? integerValue(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid $fieldName';
    }

    return null;
  }

  /// Validates double
  static String? doubleValue(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid $fieldName';
    }

    return null;
  }

  /// Validates URL format
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates date
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    final date = DateTime.tryParse(value);
    if (date == null) {
      return 'Please enter a valid date';
    }

    if (date.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }

    if (date.isBefore(DateTime(1900))) {
      return 'Date seems too old. Please check your input.';
    }

    return null;
  }

  /// Validates time
  static String? time(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }

    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Please enter a valid time (HH:MM)';
    }

    return null;
  }
}
