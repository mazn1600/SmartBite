class AppConstants {
  // App Information
  static const String appName = 'SmartBite';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered personalized nutrition and meal planning app for Saudi Arabia';

  // API Configuration
  static const String baseUrl = 'https://api.smartbite.com'; // Replace with your actual API URL
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Meal Types
  static const List<String> mealTypes = [
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  ];

  // Activity Levels
  static const List<String> activityLevels = [
    'sedentary',
    'lightly_active',
    'moderately_active',
    'very_active',
    'extremely_active',
  ];

  // Goals
  static const List<String> goals = [
    'weight_loss',
    'weight_gain',
    'maintenance',
  ];

  // Genders
  static const List<String> genders = [
    'male',
    'female',
  ];

  // Food Categories
  static const List<String> foodCategories = [
    'proteins',
    'carbohydrates',
    'vegetables',
    'fruits',
    'dairy',
    'grains',
    'nuts_seeds',
    'beverages',
    'snacks',
    'desserts',
  ];

  // Common Allergens
  static const List<String> commonAllergens = [
    'gluten',
    'dairy',
    'nuts',
    'eggs',
    'soy',
    'fish',
    'shellfish',
    'sesame',
  ];

  // Health Conditions
  static const List<String> healthConditions = [
    'diabetes',
    'hypertension',
    'heart_disease',
    'celiac_disease',
    'lactose_intolerance',
    'kidney_disease',
    'liver_disease',
  ];

  // Saudi Supermarkets
  static const List<String> saudiSupermarkets = [
    'Othaim',
    'Panda',
    'Lulu',
    'Carrefour',
    'Danube',
    'Al-Tamimi',
    'BinDawood',
    'Al-Raya',
    'HyperPanda',
    'Tamimi Markets',
  ];

  // Currency
  static const String currency = 'SAR';
  static const String currencySymbol = 'ر.س';

  // Units
  static const String weightUnit = 'kg';
  static const String heightUnit = 'cm';
  static const String temperatureUnit = '°C';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minAge = 13;
  static const int maxAge = 120;
  static const double minHeight = 100; // cm
  static const double maxHeight = 250; // cm
  static const double minWeight = 20; // kg
  static const double maxWeight = 300; // kg

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration foodCacheDuration = Duration(days: 1);
  static const Duration priceCacheDuration = Duration(hours: 6);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Error Messages
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred. Please try again.';
  static const String validationErrorMessage = 'Please check your input and try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registrationSuccessMessage = 'Registration successful!';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully!';
  static const String mealPlanSavedMessage = 'Meal plan saved successfully!';

  // Colors (you can customize these)
  static const int primaryColorValue = 0xFF2E7D32; // Green
  static const int secondaryColorValue = 0xFF4CAF50; // Light Green
  static const int accentColorValue = 0xFFFF9800; // Orange
  static const int errorColorValue = 0xFFD32F2F; // Red
  static const int warningColorValue = 0xFFFF9800; // Orange
  static const int successColorValue = 0xFF4CAF50; // Green
  static const int infoColorValue = 0xFF2196F3; // Blue

  // Font Sizes
  static const double smallFontSize = 12.0;
  static const double mediumFontSize = 14.0;
  static const double largeFontSize = 16.0;
  static const double extraLargeFontSize = 18.0;
  static const double titleFontSize = 24.0;
  static const double headingFontSize = 20.0;

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Border Radius
  static const double smallBorderRadius = 4.0;
  static const double mediumBorderRadius = 8.0;
  static const double largeBorderRadius = 12.0;
  static const double extraLargeBorderRadius = 16.0;
}
