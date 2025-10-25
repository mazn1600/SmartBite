import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/supabase_auth_service.dart';
import '../services/auth_service.dart';
import '../services/meal_generation_service.dart';
import '../models/user.dart';
import '../widgets/circular_progress_indicator.dart';
import '../widgets/macro_nutrient_card.dart';
import '../widgets/date_selector.dart';
import '../widgets/food_image_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  bool isTodayView = true;
  List<Meal>? generatedMeals;
  Set<String> eatenMealIds = {};

  @override
  void initState() {
    super.initState();
    _loadGeneratedMeals();
  }

  void _loadGeneratedMeals() {
    // Load generated meals from meal plan screen
    // For now, we'll generate them if they don't exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user != null && generatedMeals == null) {
        final meals = MealGenerationService.generatePersonalizedMeals(user);
        final adjustedMeals =
            MealGenerationService.adjustForHealthConditions(meals, user);
        setState(() {
          generatedMeals = adjustedMeals;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer2<SupabaseAuthService, AuthService>(
        builder: (context, supabaseAuthService, authService, child) {
          // Check Supabase auth first, then fallback to local auth
          final isAuthenticated = supabaseAuthService.isAuthenticated ||
              authService.currentUser != null;

          if (!isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline,
                      size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Please log in to continue',
                    style: AppTextStyles.h5,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          // Use local user for now (until we migrate fully to Supabase user model)
          final user = authService.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildDashboard(user);
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildDashboard(User user) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(user),

            // Tab Selector
            _buildTabSelector(),

            // Date Selector
            _buildDateSelector(),

            // Calorie Summary
            _buildCalorieSummary(),

            // Macronutrient Breakdown
            _buildMacroNutrientBreakdown(),

            // Today Meals Section
            _buildTodayMeals(),

            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Row(
        children: [
          // Profile picture (tap to open profile)
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          // Date and greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today ${_formatDate(selectedDate)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Good Morning',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: const [AppShadows.small],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isTodayView = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                decoration: BoxDecoration(
                  color: isTodayView ? AppColors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(
                  'Today',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelLarge.copyWith(
                    color:
                        isTodayView ? AppColors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isTodayView = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                decoration: BoxDecoration(
                  color: !isTodayView ? AppColors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(
                  'Weekly',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelLarge.copyWith(
                    color:
                        !isTodayView ? AppColors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: DateSelector(
        selectedDate: selectedDate,
        onDateChanged: (date) => setState(() => selectedDate = date),
      ),
    );
  }

  Widget _buildCalorieSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Eaten calories
          Column(
            children: [
              Text(
                '1200',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Eaten',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Icon(
                Icons.apple,
                color: AppColors.error,
                size: 20,
              ),
            ],
          ),
          // Target calories with progress
          const CalorieCircularProgress(
            eaten: 1200.0,
            target: 2000,
            burned: 500,
            size: 80,
          ),
          // Burned calories
          Column(
            children: [
              Text(
                '500',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Burned',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Icon(
                Icons.local_fire_department,
                color: AppColors.accent,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroNutrientBreakdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: const MacroNutrientGrid(
        carbs: 160,
        carbsTarget: 225,
        protein: 80,
        proteinTarget: 112,
        fats: 35,
        fatsTarget: 50,
      ),
    );
  }

  Widget _buildTodayMeals() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today Meals',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (generatedMeals != null && generatedMeals!.isNotEmpty)
                    Text(
                      '${eatenMealIds.length}/${generatedMeals!.length} completed',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/meal-plan'),
                child: Text(
                  'View All',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (generatedMeals != null && generatedMeals!.isNotEmpty) ...[
            // Show generated meals
            ...generatedMeals!
                .take(2)
                .map((meal) => _buildMealSummaryCard(meal)),
            if (generatedMeals!.length > 2) ...[
              const SizedBox(height: AppSizes.sm),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/meal-plan'),
                  child: Text(
                    '+ ${generatedMeals!.length - 2} more meals',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ] else ...[
            // Empty state
            _buildEmptyMealsState(),
          ],
        ],
      ),
    );
  }

  Widget _buildMealSummaryCard(Meal meal) {
    final isEaten = eatenMealIds.contains(meal.id);

    return GestureDetector(
      onTap: () => _showMealDetails(meal),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color:
              isEaten ? AppColors.surface.withOpacity(0.7) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
              color: isEaten
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.primary.withOpacity(0.2)),
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

            // Meal Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isEaten
                    ? AppColors.textSecondary.withOpacity(0.3)
                    : AppColors.lightGreen,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                _getMealIcon(meal.mealType),
                color: isEaten ? AppColors.textSecondary : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.md),

            // Meal Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    '${meal.foods.length} items • ${meal.totalCalories} cal',
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
                ],
              ),
            ),

            // Remove Button (only show if not eaten)
            if (!isEaten)
              IconButton(
                onPressed: () => _removeMeal(meal),
                icon: const Icon(
                  Icons.cancel_outlined,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMealsState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No meals planned for today',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Generate your personalized meal plan to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.md),
          ElevatedButton(
            onPressed: () =>
                context.go('/meal-plan', extra: {'generateMeals': true}),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: const Text('Generate Meals'),
          ),
        ],
      ),
    );
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

  void _removeMeal(Meal meal) {
    // TODO: Implement meal removal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${meal.name} removed from today\'s plan'),
        backgroundColor: AppColors.error,
      ),
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
        currentIndex: 0, // Home tab selected
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
              context.go('/meal-plan');
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
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
                    child: Icon(Icons.camera_alt, color: AppColors.primary),
                  ),
                  title: const Text('Scan Meal'),
                  subtitle:
                      const Text('Use camera to detect food and calories'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/scan-meal');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.carbBlue,
                    child:
                        Icon(Icons.qr_code_scanner, color: AppColors.primary),
                  ),
                  title: const Text('Barcode Scan'),
                  subtitle: const Text('Scan package barcode to log food'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/barcode-scan');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.fatOrange,
                    child: Icon(Icons.mic, color: AppColors.primary),
                  ),
                  title: const Text('Voice Log'),
                  subtitle: const Text('Say what you ate to log quickly'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/voice-log');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.greyLight,
                    child: const Icon(Icons.search, color: AppColors.primary),
                  ),
                  title: const Text('Log Food'),
                  subtitle: const Text('Search our database and add items'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/food-search');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
