/// Food Analysis API Request/Response Models
///
/// This file contains all data models for the Food Analysis API integration.
/// Models are organized into logical sections:
/// - Authentication models
/// - Core data models (Ingredient, Allergen, etc.)
/// - Request/Response models for each API endpoint
///
/// All models include:
/// - `fromJson()` factory constructors for deserialization
/// - `toJson()` methods for serialization
/// - Proper null safety handling

// ========== Authentication Models ==========

/// Login Request Model
///
/// Used for authenticating with the Food Analysis API.
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

/// Login Response Model
///
/// Contains authentication tokens returned from the login endpoint.
/// [expiresIn] is in milliseconds timestamp format.
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // milliseconds timestamp

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        expiresIn: json['expiresIn'] as int,
      );
}

// ========== Core Data Models ==========

/// Ingredient Model
///
/// Represents a single ingredient with optional quantity and category information.
class Ingredient {
  final String name;
  final double? quantity;
  final String? unit;
  final String? category;

  Ingredient({
    required this.name,
    this.quantity,
    this.unit,
    this.category,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'] as String,
        quantity: json['quantity'] != null
            ? (json['quantity'] as num).toDouble()
            : null,
        unit: json['unit'] as String?,
        category: json['category'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
        if (category != null) 'category': category,
      };
}

/// Allergen Model
///
/// Represents a potential allergen with severity level.
/// [severity] can be 'low', 'medium', or 'high'.
class Allergen {
  final String name;
  final String severity; // 'low', 'medium', 'high'
  final String? description;

  Allergen({
    required this.name,
    required this.severity,
    this.description,
  });

  factory Allergen.fromJson(Map<String, dynamic> json) => Allergen(
        name: json['name'] as String,
        severity: json['severity'] as String,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'severity': severity,
        if (description != null) 'description': description,
      };
}

/// Diet Compatibility Model
///
/// Represents compatibility of a dish with a specific diet type.
/// [compatibilityScore] ranges from 0.0 to 1.0.
class DietCompatibility {
  final String dietType; // 'vegan', 'vegetarian', 'keto', 'halal', etc.
  final bool isCompatible;
  final double compatibilityScore; // 0.0 to 1.0
  final List<String>? incompatibleIngredients;
  final String? reason;

  DietCompatibility({
    required this.dietType,
    required this.isCompatible,
    required this.compatibilityScore,
    this.incompatibleIngredients,
    this.reason,
  });

  factory DietCompatibility.fromJson(Map<String, dynamic> json) =>
      DietCompatibility(
        dietType: json['dietType'] as String,
        isCompatible: json['isCompatible'] as bool,
        compatibilityScore: (json['compatibilityScore'] as num).toDouble(),
        incompatibleIngredients: json['incompatibleIngredients'] != null
            ? List<String>.from(json['incompatibleIngredients'] as List)
            : null,
        reason: json['reason'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'dietType': dietType,
        'isCompatible': isCompatible,
        'compatibilityScore': compatibilityScore,
        if (incompatibleIngredients != null)
          'incompatibleIngredients': incompatibleIngredients,
        if (reason != null) 'reason': reason,
      };
}

/// Nutrient Model
///
/// Represents a single nutrient with value and unit.
/// [dailyValuePercentage] is optional and indicates % of daily recommended value.
class Nutrient {
  final String name;
  final double value;
  final String unit;
  final double? dailyValuePercentage;

  Nutrient({
    required this.name,
    required this.value,
    required this.unit,
    this.dailyValuePercentage,
  });

  factory Nutrient.fromJson(Map<String, dynamic> json) => Nutrient(
        name: json['name'] as String,
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String,
        dailyValuePercentage: json['dailyValuePercentage'] != null
            ? (json['dailyValuePercentage'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'unit': unit,
        if (dailyValuePercentage != null)
          'dailyValuePercentage': dailyValuePercentage,
      };
}

// ========== Ingredient Extraction Models ==========

/// Ingredient Extraction Request
///
/// Request model for extracting ingredients from a dish name.
class IngredientExtractionRequest {
  final String dishName;

  IngredientExtractionRequest({required this.dishName});

  Map<String, dynamic> toJson() => {
        'dishName': dishName,
      };
}

/// Ingredient Extraction Response
///
/// Response containing extracted ingredients and confidence score.
class IngredientExtractionResponse {
  final List<Ingredient> ingredients;
  final double confidence;

  IngredientExtractionResponse({
    required this.ingredients,
    required this.confidence,
  });

  factory IngredientExtractionResponse.fromJson(Map<String, dynamic> json) =>
      IngredientExtractionResponse(
        ingredients: (json['ingredients'] as List)
            .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
            .toList(),
        confidence: (json['confidence'] as num).toDouble(),
      );
}

// ========== Allergen Analysis Models ==========

/// Allergen Analysis Request (by dish)
///
/// Request model for analyzing allergens from a dish name.
class AllergenAnalysisByDishRequest {
  final String dishName;

  AllergenAnalysisByDishRequest({required this.dishName});

  Map<String, dynamic> toJson() => {
        'dishName': dishName,
      };
}

/// Allergen Analysis Request (by ingredients)
///
/// Request model for analyzing allergens from an ingredient list.
class AllergenAnalysisByIngredientsRequest {
  final List<String> ingredients;

  AllergenAnalysisByIngredientsRequest({required this.ingredients});

  Map<String, dynamic> toJson() => {
        'ingredients': ingredients,
      };
}

/// Allergen Analysis Response
///
/// Response containing identified allergens and overall risk level.
/// [riskLevel] ranges from 0.0 (no risk) to 1.0 (high risk).
class AllergenAnalysisResponse {
  final List<Allergen> allergens;
  final double riskLevel; // 0.0 to 1.0
  final String? warning;

  AllergenAnalysisResponse({
    required this.allergens,
    required this.riskLevel,
    this.warning,
  });

  factory AllergenAnalysisResponse.fromJson(Map<String, dynamic> json) =>
      AllergenAnalysisResponse(
        allergens: (json['allergens'] as List)
            .map((a) => Allergen.fromJson(a as Map<String, dynamic>))
            .toList(),
        riskLevel: (json['riskLevel'] as num).toDouble(),
        warning: json['warning'] as String?,
      );
}

/// Extract Ingredients and Analyze Allergens Response
///
/// Combined response from extract + allergen analysis endpoint.
class ExtractIngredientsAndAnalyzeAllergensResponse {
  final List<Ingredient> ingredients;
  final List<Allergen> allergens;
  final double riskLevel;
  final String? warning;

  ExtractIngredientsAndAnalyzeAllergensResponse({
    required this.ingredients,
    required this.allergens,
    required this.riskLevel,
    this.warning,
  });

  factory ExtractIngredientsAndAnalyzeAllergensResponse.fromJson(
          Map<String, dynamic> json) =>
      ExtractIngredientsAndAnalyzeAllergensResponse(
        ingredients: (json['ingredients'] as List)
            .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
            .toList(),
        allergens: (json['allergens'] as List)
            .map((a) => Allergen.fromJson(a as Map<String, dynamic>))
            .toList(),
        riskLevel: (json['riskLevel'] as num).toDouble(),
        warning: json['warning'] as String?,
      );
}

// ========== Diet Compatibility Models ==========

/// Diet Compatibility Analysis Request (by dish)
///
/// Request model for checking diet compatibility from a dish name.
/// [dietTypes] is optional - if null, checks all common diets.
class DietCompatibilityByDishRequest {
  final String dishName;
  final List<String>? dietTypes; // Optional: specific diets to check

  DietCompatibilityByDishRequest({
    required this.dishName,
    this.dietTypes,
  });

  Map<String, dynamic> toJson() => {
        'dishName': dishName,
        if (dietTypes != null) 'dietTypes': dietTypes,
      };
}

/// Diet Compatibility Analysis Request (by ingredients)
///
/// Request model for checking diet compatibility from an ingredient list.
class DietCompatibilityByIngredientsRequest {
  final List<String> ingredients;
  final List<String>? dietTypes; // Optional: specific diets to check

  DietCompatibilityByIngredientsRequest({
    required this.ingredients,
    this.dietTypes,
  });

  Map<String, dynamic> toJson() => {
        'ingredients': ingredients,
        if (dietTypes != null) 'dietTypes': dietTypes,
      };
}

/// Diet Compatibility Analysis Response
///
/// Response containing compatibility scores for multiple diets.
class DietCompatibilityResponse {
  final List<DietCompatibility> compatibilities;
  final double overallScore;

  DietCompatibilityResponse({
    required this.compatibilities,
    required this.overallScore,
  });

  factory DietCompatibilityResponse.fromJson(Map<String, dynamic> json) =>
      DietCompatibilityResponse(
        compatibilities: (json['compatibilities'] as List)
            .map((c) => DietCompatibility.fromJson(c as Map<String, dynamic>))
            .toList(),
        overallScore: (json['overallScore'] as num).toDouble(),
      );
}

/// Extract Ingredients and Analyze Diet Response
///
/// Combined response from extract + diet analysis endpoint.
class ExtractIngredientsAndAnalyzeDietResponse {
  final List<Ingredient> ingredients;
  final List<DietCompatibility> compatibilities;
  final double overallScore;

  ExtractIngredientsAndAnalyzeDietResponse({
    required this.ingredients,
    required this.compatibilities,
    required this.overallScore,
  });

  factory ExtractIngredientsAndAnalyzeDietResponse.fromJson(
          Map<String, dynamic> json) =>
      ExtractIngredientsAndAnalyzeDietResponse(
        ingredients: (json['ingredients'] as List)
            .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
            .toList(),
        compatibilities: (json['compatibilities'] as List)
            .map((c) => DietCompatibility.fromJson(c as Map<String, dynamic>))
            .toList(),
        overallScore: (json['overallScore'] as num).toDouble(),
      );
}

// ========== Nutrient Calculation Models ==========

/// Nutrient Calculation Request
///
/// Request model for calculating nutrients from ingredients.
/// [quantities] is optional - if null, uses default serving sizes.
class NutrientCalculationRequest {
  final List<String> ingredients;
  final Map<String, double>? quantities; // Optional: ingredient quantities

  NutrientCalculationRequest({
    required this.ingredients,
    this.quantities,
  });

  Map<String, dynamic> toJson() => {
        'ingredients': ingredients,
        if (quantities != null) 'quantities': quantities,
      };
}

/// Nutrient Calculation Response
///
/// Response containing detailed nutritional breakdown.
/// [macronutrients] includes protein, carbs, and fat values.
class NutrientCalculationResponse {
  final List<Nutrient> nutrients;
  final double totalCalories;
  final Map<String, double> macronutrients; // protein, carbs, fat

  NutrientCalculationResponse({
    required this.nutrients,
    required this.totalCalories,
    required this.macronutrients,
  });

  factory NutrientCalculationResponse.fromJson(Map<String, dynamic> json) =>
      NutrientCalculationResponse(
        nutrients: (json['nutrients'] as List)
            .map((n) => Nutrient.fromJson(n as Map<String, dynamic>))
            .toList(),
        totalCalories: (json['totalCalories'] as num).toDouble(),
        macronutrients: Map<String, double>.from(json['macronutrients'] as Map),
      );
}

// ========== Nutrient Label Models ==========

/// Nutrient Label Model
///
/// Represents a health-related label based on nutrient analysis.
/// [category] can be 'low', 'medium', 'high', or 'very_high'.
class NutrientLabel {
  final String label;
  final String category; // 'low', 'medium', 'high', 'very_high'
  final String? description;

  NutrientLabel({
    required this.label,
    required this.category,
    this.description,
  });

  factory NutrientLabel.fromJson(Map<String, dynamic> json) => NutrientLabel(
        label: json['label'] as String,
        category: json['category'] as String,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'category': category,
        if (description != null) 'description': description,
      };
}

/// Generate Nutrient Labels Request
///
/// Request model for generating health labels from nutrient data.
class GenerateNutrientLabelsRequest {
  final List<Nutrient> nutrients;

  GenerateNutrientLabelsRequest({required this.nutrients});

  Map<String, dynamic> toJson() => {
        'nutrients': nutrients.map((n) => n.toJson()).toList(),
      };
}

/// Generate Nutrient Labels Response
///
/// Response containing generated labels and overall health score.
/// [healthScore] ranges from 0.0 to 1.0.
class GenerateNutrientLabelsResponse {
  final List<NutrientLabel> labels;
  final double healthScore; // 0.0 to 1.0

  GenerateNutrientLabelsResponse({
    required this.labels,
    required this.healthScore,
  });

  factory GenerateNutrientLabelsResponse.fromJson(Map<String, dynamic> json) =>
      GenerateNutrientLabelsResponse(
        labels: (json['labels'] as List)
            .map((l) => NutrientLabel.fromJson(l as Map<String, dynamic>))
            .toList(),
        healthScore: (json['healthScore'] as num).toDouble(),
      );
}

/// Extract Ingredients and Calculate Nutrients Response
///
/// Combined response from extract + nutrient calculation endpoint.
class ExtractIngredientsAndCalculateNutrientsResponse {
  final List<Ingredient> ingredients;
  final List<Nutrient> nutrients;
  final double totalCalories;
  final Map<String, double> macronutrients;

  ExtractIngredientsAndCalculateNutrientsResponse({
    required this.ingredients,
    required this.nutrients,
    required this.totalCalories,
    required this.macronutrients,
  });

  factory ExtractIngredientsAndCalculateNutrientsResponse.fromJson(
          Map<String, dynamic> json) =>
      ExtractIngredientsAndCalculateNutrientsResponse(
        ingredients: (json['ingredients'] as List)
            .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
            .toList(),
        nutrients: (json['nutrients'] as List)
            .map((n) => Nutrient.fromJson(n as Map<String, dynamic>))
            .toList(),
        totalCalories: (json['totalCalories'] as num).toDouble(),
        macronutrients: Map<String, double>.from(json['macronutrients'] as Map),
      );
}

// ========== Full Pipeline Models ==========

/// Full Pipeline Request
///
/// Request model for complete analysis pipeline.
/// Performs all analyses: ingredients, allergens, diet, nutrients, and labels.
class FullPipelineRequest {
  final String dishName;
  final List<String>? dietTypes; // Optional: specific diets to check
  final Map<String, double>? quantities; // Optional: ingredient quantities

  FullPipelineRequest({
    required this.dishName,
    this.dietTypes,
    this.quantities,
  });

  Map<String, dynamic> toJson() => {
        'dishName': dishName,
        if (dietTypes != null) 'dietTypes': dietTypes,
        if (quantities != null) 'quantities': quantities,
      };
}

/// Full Pipeline Response
///
/// Comprehensive response containing all analysis data.
/// This is the most complete response model, including all analysis types.
class FullPipelineResponse {
  final List<Ingredient> ingredients;
  final List<Allergen> allergens;
  final double allergenRiskLevel;
  final List<DietCompatibility> dietCompatibilities;
  final double dietOverallScore;
  final List<Nutrient> nutrients;
  final double totalCalories;
  final Map<String, double> macronutrients;
  final List<NutrientLabel> labels;
  final double healthScore;

  FullPipelineResponse({
    required this.ingredients,
    required this.allergens,
    required this.allergenRiskLevel,
    required this.dietCompatibilities,
    required this.dietOverallScore,
    required this.nutrients,
    required this.totalCalories,
    required this.macronutrients,
    required this.labels,
    required this.healthScore,
  });

  factory FullPipelineResponse.fromJson(Map<String, dynamic> json) =>
      FullPipelineResponse(
        ingredients: (json['ingredients'] as List)
            .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
            .toList(),
        allergens: (json['allergens'] as List)
            .map((a) => Allergen.fromJson(a as Map<String, dynamic>))
            .toList(),
        allergenRiskLevel: (json['allergenRiskLevel'] as num).toDouble(),
        dietCompatibilities: (json['dietCompatibilities'] as List)
            .map((c) => DietCompatibility.fromJson(c as Map<String, dynamic>))
            .toList(),
        dietOverallScore: (json['dietOverallScore'] as num).toDouble(),
        nutrients: (json['nutrients'] as List)
            .map((n) => Nutrient.fromJson(n as Map<String, dynamic>))
            .toList(),
        totalCalories: (json['totalCalories'] as num).toDouble(),
        macronutrients: Map<String, double>.from(json['macronutrients'] as Map),
        labels: (json['labels'] as List)
            .map((l) => NutrientLabel.fromJson(l as Map<String, dynamic>))
            .toList(),
        healthScore: (json['healthScore'] as num).toDouble(),
      );
}
