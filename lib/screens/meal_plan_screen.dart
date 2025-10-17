import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_theme.dart';
import '../services/auth_service.dart';
import '../services/meal_generation_service.dart';
import '../models/user.dart';
import '../models/meal_food.dart';
import '../services/price_comparison_service.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  List<Meal>? generatedMeals;
  bool isLoading = false;
  final Set<String> _expandedMealIds = {};

  @override
  Widget build(BuildContext context) {
    // Check if we should generate meals
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final shouldGenerateMeals = extra?['generateMeals'] == true;

    if (shouldGenerateMeals && generatedMeals == null && !isLoading) {
      _generateMeals();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AuthService>(
          builder: (context, authService, child) {
            if (authService.currentUser == null) {
              return const Center(
                child: Text('Please log in to view meal plans'),
              );
            }

            return _buildMealPlanContent(authService.currentUser!);
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildMealPlanContent(User user) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'Generating your personalized meals...',
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      );
    }

    if (generatedMeals == null) {
      return _buildEmptyState();
    }

    return _buildMealPlanList(user);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            'Your Personalized Meal Plan',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'Get AI-powered meal recommendations\nbased on your preferences and goals',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xl),
          ElevatedButton(
            onPressed: _generateMeals,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.xl,
                vertical: AppSizes.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome),
                SizedBox(width: AppSizes.sm),
                Text(
                  'Generate My Day',
                  style: AppTextStyles.buttonLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanList(User user) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(user),

          // Daily Summary
          _buildDailySummary(),

          // Meals List
          _buildMealsList(),

          const SizedBox(height: 100), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Meal Plan',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Generated for ${user.name}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _generateMeals,
            icon: const Icon(
              Icons.refresh,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary() {
    if (generatedMeals == null) return const SizedBox.shrink();

    final totalCalories =
        generatedMeals!.fold(0, (sum, meal) => sum + meal.totalCalories);
    final totalProtein =
        generatedMeals!.fold(0.0, (sum, meal) => sum + meal.totalProtein);
    final totalCarbs =
        generatedMeals!.fold(0.0, (sum, meal) => sum + meal.totalCarbs);
    final totalFat =
        generatedMeals!.fold(0.0, (sum, meal) => sum + meal.totalFat);
    final totalPrice = generatedMeals!
        .fold(0.0, (sum, meal) => sum + _calculateMealPrice(meal));

    return Container(
      margin: const EdgeInsets.all(AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Summary',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Calories', '$totalCalories', 'kcal'),
              ),
              Expanded(
                child: _buildSummaryItem(
                    'Protein', '${totalProtein.toInt()}', 'g'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Carbs', '${totalCarbs.toInt()}', 'g'),
              ),
              Expanded(
                child: _buildSummaryItem('Fat', '${totalFat.toInt()}', 'g'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          // Total cost row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.attach_money,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  'Total Daily Cost: ',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${totalPrice.toStringAsFixed(2)} SAR',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$label ($unit)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList() {
    if (generatedMeals == null) return const SizedBox.shrink();

    return Column(
      children: generatedMeals!.map((meal) => _buildMealCard(meal)).toList(),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          GestureDetector(
            onTap: () {
              setState(() {
                if (_expandedMealIds.contains(meal.id)) {
                  _expandedMealIds.remove(meal.id);
                } else {
                  _expandedMealIds.add(meal.id);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusLg),
                  topRight: Radius.circular(AppSizes.radiusLg),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getMealIcon(meal.mealType),
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      meal.name,
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${meal.totalCalories} cal',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Icon(
                    _expandedMealIds.contains(meal.id)
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          if (_expandedMealIds.contains(meal.id)) ...[
            // Detailed visual header (image + calories/macros)
            _buildMealDetailHeader(meal),

            // Food items
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                children:
                    meal.foods.map((food) => _buildFoodItem(food)).toList(),
              ),
            ),

            // Nutritional summary for the meal
            _buildMealNutritionSummary(meal),

            // Price summary for the meal
            _buildMealPriceSummary(meal),

            // Price breakdown for key ingredients
            _buildMealPriceBreakdown(meal),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodItem(MealFood food) {
    String ingredientHint(MealFood f) {
      switch (f.category) {
        case 'protein':
          return 'Lean protein source. Helps with satiety and recovery.';
        case 'carbohydrate':
          return 'Complex carbs for stable energy.';
        case 'vegetable':
          return 'Rich in fiber, vitamins and minerals.';
        case 'fruit':
          return 'Natural sugars and antioxidants.';
        case 'healthy_fat':
          return 'Healthy fats support hormone health.';
        case 'snack':
          return 'Balanced snack option.';
        default:
          return 'Great addition to balance this meal.';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              boxShadow: const [AppShadows.small],
            ),
            child: const Icon(
              Icons.fastfood,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        food.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${food.calories} Cal',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Serving: ${food.servingSize}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ingredientHint(food),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _macroChip(
                        'P', '${food.protein.toInt()}g', AppColors.primary),
                    const SizedBox(width: 6),
                    _macroChip('C', '${food.carbs.toInt()}g', AppColors.info),
                    const SizedBox(width: 6),
                    _macroChip('F', '${food.fat.toInt()}g', AppColors.accent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        currentIndex: 1, // Meals tab selected
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Meals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              // Already on meals
              break;
            case 2:
              // Add food item
              break;
            case 3:
              context.go('/progress');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildMealNutritionSummary(Meal meal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Nutritional Summary',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem('Protein',
                    '${meal.totalProtein.toInt()}g', AppColors.primary),
              ),
              Expanded(
                child: _buildNutritionItem(
                    'Carbs', '${meal.totalCarbs.toInt()}g', AppColors.info),
              ),
              Expanded(
                child: _buildNutritionItem(
                    'Fat', '${meal.totalFat.toInt()}g', AppColors.accent),
              ),
              Expanded(
                child: _buildNutritionItem(
                    'Fiber', '${meal.totalFiber.toInt()}g', AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealPriceSummary(Meal meal) {
    // Calculate estimated price for the meal
    final estimatedPrice = _calculateMealPrice(meal);

    return Container(
      margin: const EdgeInsets.all(AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.attach_money,
            color: AppColors.accent,
            size: 20,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            'Estimated Cost: ',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${estimatedPrice.toStringAsFixed(2)} SAR',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              'Budget Friendly',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPriceBreakdown(Meal meal) {
    final priceService =
        Provider.of<PriceComparisonService>(context, listen: false);

    // Map meal food names to known pricing IDs (demo mapping)
    String? mapFoodToPriceId(String name) {
      final lower = name.toLowerCase();
      if (lower.contains('chicken')) return '1';
      if (lower.contains('salmon')) return '2';
      if (lower.contains('rice')) return '3';
      return null; // unknown
    }

    final lines = <Widget>[];
    for (final food in meal.foods) {
      final priceId = mapFoodToPriceId(food.name);
      if (priceId == null) continue;
      final options = priceService.findCheapestPrices(priceId);
      if (options.isEmpty) continue;
      final best = options.first;
      lines.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.sm),
          child: Row(
            children: [
              const Icon(Icons.local_grocery_store,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  '${food.name} ${best.unit}: ${best.effectivePrice.toStringAsFixed(2)} ${best.currency} at ${best.storeName}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg, vertical: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store_mall_directory,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Closest Supermarket Prices',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ...lines,
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // Visual header similar to provided design: big image and macro summary
  Widget _buildMealDetailHeader(Meal meal) {
    final colors = _getMealHeaderColors(meal.mealType);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusLg),
          bottomRight: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      child: Row(
        children: [
          // Circular image placeholder
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [AppShadows.medium],
            ),
            child: Center(
              child: Icon(
                _getMealIcon(meal.mealType),
                color: AppColors.primary,
                size: 36,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _kvPill(
                        '${meal.totalCalories}', 'Calories', AppColors.error),
                    const SizedBox(width: 8),
                    _kvPill('${meal.totalProtein.toInt()}g', 'Protein',
                        AppColors.primary),
                    const SizedBox(width: 8),
                    _kvPill(
                        '${meal.totalCarbs.toInt()}g', 'Carbs', AppColors.info),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kvPill(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(value,
              style: AppTextStyles.labelLarge
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _macroChip(String key, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(key,
              style: AppTextStyles.labelSmall
                  .copyWith(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          Text(value,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  List<Color> _getMealHeaderColors(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return [AppColors.fatOrange, AppColors.accentLight.withOpacity(0.4)];
      case 'lunch':
        return [AppColors.lightGreen, AppColors.primaryLight.withOpacity(0.3)];
      case 'dinner':
        return [AppColors.carbBlue, AppColors.info.withOpacity(0.3)];
      case 'snack':
        return [AppColors.surfaceVariant, AppColors.greyLight.withOpacity(0.5)];
      default:
        return [AppColors.lightGreen, AppColors.primaryLight.withOpacity(0.3)];
    }
  }

  double _calculateMealPrice(Meal meal) {
    // Simple price calculation based on food categories and calories
    double totalPrice = 0.0;

    for (final food in meal.foods) {
      double basePrice = 0.0;

      switch (food.category) {
        case 'protein':
          basePrice = 0.15; // 15 SAR per 100 calories for protein
          break;
        case 'carbohydrate':
          basePrice = 0.08; // 8 SAR per 100 calories for carbs
          break;
        case 'vegetable':
          basePrice = 0.12; // 12 SAR per 100 calories for vegetables
          break;
        case 'fruit':
          basePrice = 0.10; // 10 SAR per 100 calories for fruits
          break;
        case 'healthy_fat':
          basePrice = 0.20; // 20 SAR per 100 calories for healthy fats
          break;
        case 'snack':
          basePrice = 0.18; // 18 SAR per 100 calories for snacks
          break;
        default:
          basePrice = 0.12; // Default price
      }

      totalPrice += (food.calories / 100) * basePrice;
    }

    return totalPrice;
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.wb_sunny_outlined;
      case 'dinner':
        return Icons.nights_stay;
      case 'snack':
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }

  void _generateMeals() async {
    setState(() {
      isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    final authService =
        Provider.of<AuthService>(BuildContext as BuildContext, listen: false);
    final user = authService.currentUser;

    if (user != null) {
      final meals = MealGenerationService.generatePersonalizedMeals(user);
      final adjustedMeals =
          MealGenerationService.adjustForHealthConditions(meals, user);

      setState(() {
        generatedMeals = adjustedMeals;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}
