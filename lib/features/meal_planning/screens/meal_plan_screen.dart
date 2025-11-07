import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../services/meal_generation_service.dart';
import '../services/meal_plan_service.dart';
import '../../food/services/food_analysis_service.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/models/meal_food.dart';
import '../../../../shared/models/meal_plan.dart';
import '../../store/services/price_comparison_service.dart';
import '../../../../shared/widgets/food_image_widget.dart';
import '../../../../shared/widgets/app_refresh_wrapper.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen>
    with AutomaticKeepAliveClientMixin {
  List<Meal>? generatedMeals;
  bool isLoading = false;
  bool isSaving = false;
  DateTime selectedDate = DateTime.now();
  Set<String> eatenMealIds = {};
  final _uuid = const Uuid();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load meals for current date after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMealsForDate(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Check if we should generate meals
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final shouldGenerateMeals = extra?['generateMeals'] == true;

    if (shouldGenerateMeals && generatedMeals == null && !isLoading) {
      _generateMeals();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Planner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Add menu options
            },
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.currentUser == null) {
            return const Center(
              child: Text('Please log in to view meal plans'),
            );
          }

          return _buildPlannerContent(authService.currentUser!);
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildPlannerContent(User user) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'Generating your personalized meals...',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSizes.md),
            TextButton(
              onPressed: () {
                setState(() {
                  isLoading = false;
                });
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    return AppRefreshWrapper(
      onRefresh: () async {
        debugPrint('🔁 Refreshing meal plan for $selectedDate...');
        await _loadMealsForDate(selectedDate);
      },
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('meal_plan_scroll'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          _buildDateSelector(),

          // Date and Total Calories
          _buildDateAndCalories(),

          // Generate Meals Button (if no meals)
          if (generatedMeals == null || generatedMeals!.isEmpty) ...[
            _buildGenerateMealsButton(),
            const SizedBox(height: AppSizes.lg),
          ],

          // Meal Sections
          _buildMealSections(),

          const SizedBox(height: 100), // Space for bottom navigation
        ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 3));
          final isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
              // Reload meals for the new date
              _loadMealsForDate(date);
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: AppSizes.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayAbbreviation(date.weekday),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateAndCalories() {
    final totalCalories =
        generatedMeals?.fold(0, (sum, meal) => sum + meal.totalCalories) ?? 0;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(selectedDate),
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Total calories $totalCalories kcal',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (generatedMeals != null && generatedMeals!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              '${eatenMealIds.length}/${generatedMeals!.length} meals completed',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenerateMealsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : _generateMeals,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(
            isLoading ? 'Generating...' : 'Generate My Meals',
            style: AppTextStyles.buttonLarge,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildMealSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Column(
        children: [
          _buildMealSection('Breakfast', 'breakfast', Icons.wb_sunny),
          const SizedBox(height: AppSizes.lg),
          _buildMealSection('Lunch', 'lunch', Icons.wb_sunny_outlined),
          const SizedBox(height: AppSizes.lg),
          _buildMealSection('Dinner', 'dinner', Icons.nights_stay),
          const SizedBox(height: AppSizes.lg),
          _buildMealSection('Snacks', 'snack', Icons.local_cafe),
        ],
      ),
    );
  }

  Widget _buildMealSection(String title, String mealType, IconData icon) {
    final meal =
        generatedMeals?.where((m) => m.mealType == mealType).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (meal != null)
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: () => _showMealOptionsMenu(meal),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        if (meal != null)
          _buildMealCard(meal)
        else
          _buildEmptyMealCard(mealType),
      ],
    );
  }

  Widget _buildMealCard(Meal meal) {
    final isEaten = eatenMealIds.contains(meal.id);

    return GestureDetector(
      onTap: () => _showMealDetails(meal),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color:
              isEaten ? AppColors.surface.withOpacity(0.7) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
              color: isEaten
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.primary.withOpacity(0.3)),
          boxShadow: const [AppShadows.small],
        ),
        child: Row(
          children: [
            // Check Button
            GestureDetector(
              onTap: () => _toggleMealEaten(meal),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isEaten ? AppColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isEaten ? AppColors.success : AppColors.borderLight,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  color: isEaten ? AppColors.white : AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),

            // Meal Image Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isEaten
                    ? AppColors.textSecondary.withOpacity(0.3)
                    : AppColors.lightGreen,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                _getMealIcon(meal.mealType),
                color: isEaten ? AppColors.textSecondary : AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            // Meal Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Wrap(
                    spacing: AppSizes.xs,
                    children: [
                      _buildTag('High Protein', AppColors.primary),
                      _buildTag('Energy Boost', AppColors.accent),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xs),
                  // Meal Name
                  Text(
                    meal.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isEaten
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      decoration: isEaten
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Ingredients
                  Text(
                    meal.foods.map((f) => f.name).join(' · '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isEaten
                          ? AppColors.textSecondary.withOpacity(0.7)
                          : AppColors.textSecondary,
                      decoration: isEaten
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  // Calories and Time
                  Row(
                    children: [
                      Text(
                        '${meal.totalCalories} kcal',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isEaten
                              ? AppColors.textSecondary
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: isEaten
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Text(
                        '15 mins',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isEaten
                              ? AppColors.textSecondary.withOpacity(0.7)
                              : AppColors.textSecondary,
                          decoration: isEaten
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (isEaten)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMealCard(String mealType) {
    String message;
    String buttonText;

    switch (mealType) {
      case 'breakfast':
        message = 'Start your day with a healthy breakfast';
        buttonText = '+ Add Breakfast';
        break;
      case 'lunch':
        message = 'Add a nutritious lunch to keep you energized';
        buttonText = '+ Add Lunch';
        break;
      case 'dinner':
        message = 'Plan a satisfying dinner to end your day';
        buttonText = '+ Add Dinner';
        break;
      case 'snack':
        message = 'Add healthy snacks to fuel your day';
        buttonText = '+ Add Snack';
        break;
      default:
        message = 'Add a meal to your plan';
        buttonText = '+ Add Meal';
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.md),
          ElevatedButton(
            onPressed: () => _showAddMealModal(mealType),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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
          FoodImageWidget(
            imagePath: food.imageUrl, // Assuming MealFood has imageUrl property
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
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
              _showAddOptions();
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
      final optionsResult = priceService.findCheapestPrices(priceId);
      if (optionsResult.isError ||
          optionsResult.data == null ||
          optionsResult.data!.isEmpty) continue;
      final best = optionsResult.data!.first;
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

  void _showMealOptionsMenu(Meal meal) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meal Options',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'What would you like to do with "${meal.name}"?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Change Meal Option
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightGreen,
                    child: Icon(Icons.swap_horiz, color: AppColors.primary),
                  ),
                  title: const Text('Change Meal'),
                  subtitle:
                      const Text('Generate a new meal for this time slot'),
                  onTap: () {
                    Navigator.pop(context);
                    _generateNewMealForType(meal.mealType);
                  },
                ),

                // Add Another Meal Option
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightGreen,
                    child: Icon(Icons.add, color: AppColors.primary),
                  ),
                  title: const Text('Add Another Meal'),
                  subtitle:
                      const Text('Add an additional meal to this time slot'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddMealModal(meal.mealType);
                  },
                ),

                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMealDetails(Meal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  '${meal.totalCalories} calories • ${meal.foods.length} ingredients',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Ingredients List
                Text(
                  'Ingredients:',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                ...meal.foods
                    .map((food) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.xs),
                          child: Row(
                            children: [
                              const Icon(Icons.circle,
                                  size: 6, color: AppColors.primary),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Text(
                                  '${food.name} (${food.servingSize})',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${food.calories} cal',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),

                const SizedBox(height: AppSizes.lg),

                // Nutrition Summary
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutritionChip(
                          'Protein',
                          '${meal.foods.fold(0.0, (sum, f) => sum + f.protein).toInt()}g',
                          AppColors.primary),
                      _buildNutritionChip(
                          'Carbs',
                          '${meal.foods.fold(0.0, (sum, f) => sum + f.carbs).toInt()}g',
                          AppColors.info),
                      _buildNutritionChip(
                          'Fat',
                          '${meal.foods.fold(0.0, (sum, f) => sum + f.fat).toInt()}g',
                          AppColors.accent),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutritionChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
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

  void _showAddMealModal(String mealType) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add ${mealType.toLowerCase()}',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Choose how you\'d like to add a meal to your ${mealType.toLowerCase()} plan.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Choose Recipe Card
                _buildAddOptionCard(
                  'Choose Recipe',
                  'Browse our recipe collection with detailed nutrition information and cooking',
                  Icons.restaurant_menu,
                  () {
                    Navigator.pop(context);
                    // TODO: Navigate to recipe browser
                  },
                ),

                const SizedBox(height: AppSizes.md),

                // Custom Meal Card
                _buildAddOptionCard(
                  'Custom Meal',
                  'Create your own meal with custom nutrition information and details',
                  Icons.edit,
                  () {
                    Navigator.pop(context);
                    _showCustomMealForm(mealType);
                  },
                ),

                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddOptionCard(
      String title, String description, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Text('Browse Recipes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomMealForm(String mealType) {
    // TODO: Implement custom meal form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Custom meal form for $mealType - Coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add to your day',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightGreen,
                    child:
                        Icon(Icons.restaurant_menu, color: AppColors.primary),
                  ),
                  title: const Text('Add Meal'),
                  subtitle: const Text('Add a meal to your plan'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddMealModal('meal');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightGreen,
                    child: Icon(Icons.camera_alt, color: AppColors.primary),
                  ),
                  title: const Text('Scan Food'),
                  subtitle: const Text('Scan barcode or take photo'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/barcode-scan');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightGreen,
                    child: Icon(Icons.add_box, color: AppColors.primary),
                  ),
                  title: const Text('Add Food'),
                  subtitle: const Text('Add new food to database'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/add-food');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightGreen,
                    child: Icon(Icons.mic, color: AppColors.primary),
                  ),
                  title: const Text('Voice Log'),
                  subtitle: const Text('Log food by speaking'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/voice-log');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDayAbbreviation(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  void _toggleMealEaten(Meal meal) {
    setState(() {
      if (eatenMealIds.contains(meal.id)) {
        eatenMealIds.remove(meal.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal.name} marked as not eaten'),
            backgroundColor: AppColors.info,
          ),
        );
      } else {
        eatenMealIds.add(meal.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal.name} marked as eaten! ✓'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  void _generateNewMealForType(String mealType) async {
    print('Generating new meal for type: $mealType');
    setState(() {
      isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user != null) {
        // Calculate target calories for this meal type
        final Map<String, double> mealCalorieDistribution = {
          'breakfast': 0.25,
          'lunch': 0.35,
          'dinner': 0.30,
          'snack': 0.10,
        };
        final targetCalories = user.targetCalories;
        final mealCalories = (targetCalories * 
            (mealCalorieDistribution[mealType] ?? 0.25)).round();
        
        // Use async API method - no hardcoded fallback
        final foodService = FoodAnalysisService();
        final dishName = _generateDishNameForMealType(user, mealType, mealCalories);
        
        if (dishName.isEmpty) {
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to generate dish name for $mealType'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        // Get diet types from user preferences
        final dietTypes = _convertUserPreferencesToDietTypes(user);

        // Call Food Analysis API
        final result = await foodService.fullPipelineAnalysis(
          dishName,
          dietTypes: dietTypes,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Request timeout', const Duration(seconds: 10));
          },
        );

        if (result.isSuccess && result.data != null) {
          // Convert API response to Meal
          final newMeal = MealGenerationService.convertFullPipelineToMeal(
            result.data!,
            mealType,
            mealCalories,
            user,
            dishName,
          );

          setState(() {
            if (generatedMeals == null) {
              generatedMeals = [newMeal];
            } else {
              // Remove existing meal of this type and add new one
              generatedMeals!.removeWhere((m) => m.mealType == mealType);
              generatedMeals!.add(newMeal);
            }
            isLoading = false;
          });
          print('Successfully generated new $mealType meal from API');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully regenerated $mealType'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to generate $mealType from API'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          print('Failed to generate new meal from API: ${result.error}');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('No user found for meal generation');
      }
    } catch (e, stackTrace) {
      print('ERROR in meal generation: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error regenerating meal: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Helper methods for meal generation
  String _generateDishNameForMealType(User user, String mealType, int targetCalories) {
    final List<String> dishOptions = [];

    switch (mealType) {
      case 'breakfast':
        if (user.foodPreferences.contains('protein') ||
            user.goal == 'weight_loss') {
          dishOptions.addAll([
            'High Protein Breakfast Bowl',
            'Protein-Packed Scrambled Eggs',
            'Breakfast Protein Smoothie Bowl',
          ]);
        } else if (user.foodPreferences.contains('vegetables')) {
          dishOptions.addAll([
            'Vegetable Omelet',
            'Mediterranean Breakfast Bowl',
            'Green Breakfast Smoothie',
          ]);
        } else {
          dishOptions.addAll([
            'Classic Breakfast Platter',
            'Balanced Morning Meal',
            'Traditional Breakfast',
          ]);
        }
        break;

      case 'lunch':
        if (user.foodPreferences.contains('protein')) {
          dishOptions.addAll([
            'Grilled Chicken Lunch',
            'Protein-Rich Lunch Bowl',
            'High Protein Mediterranean Lunch',
          ]);
        } else if (user.foodPreferences.contains('vegetables')) {
          dishOptions.addAll([
            'Mediterranean Quinoa Bowl',
            'Vegetable Lunch Salad',
            'Healthy Mediterranean Lunch',
          ]);
        } else {
          dishOptions.addAll([
            'Balanced Lunch Meal',
            'Traditional Lunch Platter',
            'Complete Lunch Bowl',
          ]);
        }
        break;

      case 'dinner':
        if (user.foodPreferences.contains('protein')) {
          dishOptions.addAll([
            'Grilled Chicken Dinner',
            'Protein-Rich Dinner Bowl',
            'High Protein Mediterranean Dinner',
          ]);
        } else if (user.foodPreferences.contains('vegetables')) {
          dishOptions.addAll([
            'Mediterranean Dinner Bowl',
            'Vegetable Dinner Platter',
            'Healthy Mediterranean Dinner',
          ]);
        } else {
          dishOptions.addAll([
            'Balanced Dinner Meal',
            'Traditional Dinner Platter',
            'Complete Dinner Bowl',
          ]);
        }
        break;

      case 'snack':
        dishOptions.addAll([
          'Energy Snack Mix',
          'Healthy Snack Bowl',
          'Nutritious Snack Platter',
        ]);
        break;
    }

    if (dishOptions.isNotEmpty) {
      return dishOptions[0];
    }

    return mealType.substring(0, 1).toUpperCase() + mealType.substring(1) + ' Meal';
  }

  List<String> _convertUserPreferencesToDietTypes(User user) {
    final dietTypes = <String>[];

    if (user.foodPreferences.contains('vegetarian') ||
        user.foodPreferences.contains('vegetables')) {
      dietTypes.add('vegetarian');
    }

    if (user.foodPreferences.contains('vegan')) {
      dietTypes.add('vegan');
    }

    if (user.goal == 'weight_loss') {
      dietTypes.add('low_calorie');
    }

    return dietTypes;
  }

  // ========== Meal Conversion Helpers ==========

  /// Converts Meal (with List<MealFood>) to MealPlan (with List<MealItem>) for persistence
  MealPlan _convertMealToMealPlan(Meal meal, DateTime date, String userId) {
    final mealItems = meal.foods.map((food) {
      // Convert serving size to quantity in grams
      // Try to parse serving size (e.g., "100g", "1 cup", "120g")
      double quantity = 100.0; // Default to 100g
      final servingSize = food.servingSize.toLowerCase();
      if (servingSize.isNotEmpty && servingSize.contains('g')) {
        final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(servingSize);
        if (match != null) {
          quantity = double.tryParse(match.group(1)!) ?? 100.0;
        }
      } else {
        // For non-gram serving sizes, estimate based on calories
        // Rough estimate: 1 calorie ≈ 1g for most foods
        quantity = food.calories.toDouble();
      }

      // Ensure required fields are not null or empty
      final foodId = (food.id.isEmpty) ? _uuid.v4() : food.id;
      final foodName = (food.name.isEmpty) ? 'Unknown Food' : food.name;
      final foodCategory = (food.category.isEmpty) ? 'Unknown Category' : food.category;

      return MealItem(
        id: _uuid.v4(),
        foodId: foodId,
        foodName: foodName,
        quantity: quantity,
        calories: food.calories.toDouble(),
        protein: food.protein,
        carbs: food.carbs,
        fat: food.fat,
        cost: 0.0, // Will be calculated from price comparison if available
        notes: foodCategory,
      );
    }).toList();

    // Calculate totals
    double totalCalories =
        mealItems.fold(0.0, (sum, item) => sum + item.calories);
    double totalProtein =
        mealItems.fold(0.0, (sum, item) => sum + item.protein);
    double totalCarbs = mealItems.fold(0.0, (sum, item) => sum + item.carbs);
    double totalFat = mealItems.fold(0.0, (sum, item) => sum + item.fat);
    double totalCost = mealItems.fold(0.0, (sum, item) => sum + item.cost);

    return MealPlan(
      id: _uuid.v4(),
      userId: userId,
      date: date,
      mealType: meal.mealType,
      items: mealItems,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      totalCost: totalCost,
      notes: meal.name,
      rating: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Converts MealPlan (with List<MealItem>) to Meal (with List<MealFood>) for display
  Meal _convertMealPlanToMeal(MealPlan mealPlan) {
    final mealFoods = mealPlan.items.map((item) {
      // Convert quantity back to readable serving size
      String servingSize = '${item.quantity.toInt()}g';
      if (item.quantity >= 1000) {
        servingSize = '${(item.quantity / 1000).toStringAsFixed(1)}kg';
      }

      // Infer category from meal type or food name
      String category = mealPlan.mealType;
      if (item.foodName.toLowerCase().contains('chicken') ||
          item.foodName.toLowerCase().contains('beef') ||
          item.foodName.toLowerCase().contains('fish')) {
        category = 'protein';
      } else if (item.foodName.toLowerCase().contains('rice') ||
          item.foodName.toLowerCase().contains('bread') ||
          item.foodName.toLowerCase().contains('pasta')) {
        category = 'carbohydrate';
      } else if (item.foodName.toLowerCase().contains('salad') ||
          item.foodName.toLowerCase().contains('vegetable')) {
        category = 'vegetable';
      }

      return MealFood(
        id: item.foodId,
        name: item.foodName,
        calories: item.calories.toInt(),
        protein: item.protein,
        carbs: item.carbs,
        fat: item.fat,
        fiber: 0.0, // Not stored in MealItem
        sugar: 0.0, // Not stored in MealItem
        sodium: 0.0, // Not stored in MealItem
        servingSize: servingSize,
        category: category,
        imageUrl: '', // Not stored in MealItem
      );
    }).toList();

    return Meal(
      id: mealPlan.id,
      name: mealPlan.notes ?? mealPlan.mealType,
      foods: mealFoods,
      totalCalories: mealPlan.totalCalories.toInt(),
      mealType: mealPlan.mealType,
      createdAt: mealPlan.createdAt,
    );
  }

  // ========== Meal Persistence Methods ==========

  /// Loads meals from Supabase for a specific date
  /// [showLoading] - If true, shows loading indicator. Defaults to true.
  Future<void> _loadMealsForDate(DateTime date, {bool showLoading = true}) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      return;
    }

    final mealPlanService =
        Provider.of<MealPlanService>(context, listen: false);

    try {
      if (showLoading) {
        setState(() {
          isLoading = true;
        });
      }

      final result = await mealPlanService.getMealPlansByDate(user.id, date);

      if (result.isSuccess && result.data != null) {
        final mealPlans = result.data!;
        
        // Convert MealPlans to Meals for display
        final meals =
            mealPlans.map((plan) => _convertMealPlanToMeal(plan)).toList();

        setState(() {
          // Only update if we got meals, otherwise keep current meals (don't clear on empty load)
          if (meals.isNotEmpty) {
            generatedMeals = meals;
          } else if (showLoading) {
            // Only clear if this was an explicit load (not a background reload)
            generatedMeals = null;
          }
          // Otherwise, keep current generatedMeals if this was a background reload
          if (showLoading) {
            isLoading = false;
          }
        });
      } else {
        setState(() {
          // Only clear if this was an explicit load (not a background reload)
          if (showLoading) {
            generatedMeals = null;
          }
          // Otherwise, keep current generatedMeals if this was a background reload
          if (showLoading) {
            isLoading = false;
          }
        });
      }
    } catch (e) {
      print('Error loading meals for date: $e');
      // Don't clear meals on error - keep what's displayed
      if (showLoading) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Saves generated meals to Supabase
  Future<void> _saveMealsToSupabase(
      List<Meal> meals, DateTime date, String userId) async {
    if (meals.isEmpty) {
      print('⚠️ No meals to save');
      return;
    }

    print('💾 Starting to save ${meals.length} meals to Supabase...');
    print('📅 Date: ${date.toIso8601String().split('T')[0]}');
    print('👤 User ID: $userId');

    final mealPlanService =
        Provider.of<MealPlanService>(context, listen: false);

    setState(() {
      isSaving = true;
    });

    int successCount = 0;
    int failCount = 0;
    List<String> errors = [];

    for (final meal in meals) {
      try {
        print('💾 Saving meal: ${meal.name} (${meal.mealType})');
        final mealPlan = _convertMealToMealPlan(meal, date, userId);
        
        print('   📊 Meal has ${mealPlan.items.length} items');
        print('   🔢 Total calories: ${mealPlan.totalCalories}');
        
        final result = await mealPlanService.createMealPlan(
          userId: userId,
          date: date,
          mealType: meal.mealType,
          items: mealPlan.items,
          notes: meal.name,
        );

        if (result.isSuccess) {
          successCount++;
          print('   ✅ Successfully saved: ${meal.name}');
        } else {
          failCount++;
          final errorMsg = result.error ?? 'Unknown error';
          errors.add('${meal.name}: $errorMsg');
          print('   ❌ Failed to save ${meal.name}: $errorMsg');
        }
      } catch (e, stackTrace) {
        failCount++;
        final errorMsg = 'Exception: ${e.toString()}';
        errors.add('${meal.name}: $errorMsg');
        print('   ❌ Error saving meal ${meal.name}: $e');
        print('   Stack trace: $stackTrace');
      }
    }

    setState(() {
      isSaving = false;
    });

    print('💾 Save complete: $successCount succeeded, $failCount failed');

    // Show feedback to user
    if (failCount > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved $successCount meals. $failCount failed.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                ),
                if (errors.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Errors: ${errors.take(2).join(", ")}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
                    ),
                  ),
              ],
            ),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Successfully saved ${meals.length} meals to database!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _generateMeals() async {
    print('🍽️ Starting meal generation...');
    setState(() {
      isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) {
        print('❌ ERROR: No user found for meal generation');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to generate meals'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() {
          isLoading = false;
        });
        return;
      }

      print('✅ User found: ${user.name}');
      print('📊 Target calories: ${user.targetCalories}');
      print('🎯 Goal: ${user.goal}');

      // Generate meals with timeout
      print('🔄 Generating meals...');
      final meals = await MealGenerationService.generatePersonalizedMealsAsync(user)
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ Meal generation timed out');
          // Return empty list - no fallback meals
          return <Meal>[];
        },
      );

      print('✅ Generated ${meals.length} meals');

        if (meals.isEmpty) {
        print('❌ ERROR: No meals generated!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate meals. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
          setState(() {
            isLoading = false;
          });
          return;
        }

        // Update UI immediately with generated meals
        setState(() {
          generatedMeals = meals;
          isLoading = false;
        });

        // Database saving is disabled for now
        // Meals are displayed but not persisted to database
        print('✅ Meals generated and displayed (database saving disabled)');

      print('✅ Meal generation completed successfully!');
    } catch (e, stackTrace) {
      print('❌ ERROR in meal generation: $e');
      print('Stack trace: $stackTrace');
      
      // No fallback - show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate meals from API: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      setState(() {
        isLoading = false;
      });
    }
  }
}
