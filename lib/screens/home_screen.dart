import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../widgets/circular_progress_indicator.dart';
import '../widgets/macro_nutrient_card.dart';
import '../widgets/meal_item_card.dart';
import '../widgets/date_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  bool isTodayView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.currentUser == null) {
            return const Center(
              child: Text('Please log in to continue'),
            );
          }

          return _buildDashboard(authService.currentUser!);
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

            // Generate My Day Button
            _buildGenerateDayButton(),

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

  Widget _buildGenerateDayButton() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.lg),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to meal plan screen with generated meals
          context.go('/meal-plan', extra: {'generateMeals': true});
        },
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
            Icon(Icons.refresh),
            SizedBox(width: AppSizes.sm),
            Text(
              'Generate My Day',
              style: AppTextStyles.buttonLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMeals() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today Meals',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          MealSection(
            mealName: 'Breakfast',
            calories: '75.95',
            items: [
              MealItem(
                name: 'Saltine Crackers',
                calories: '63',
                onAdd: () {
                  context.push('/food-detail', extra: {
                    'foodName': 'Saltine Crackers',
                    'imageUrl': '',
                    'calories': 63.0,
                    'carbs': 11.2,
                    'protein': 1.4,
                    'fat': 0.3,
                  });
                },
                onCheck: () {},
                onRemove: () {},
              ),
            ],
            onAddItem: () {
              context.push('/food-detail', extra: {
                'foodName': 'Grilled Chicken Salad',
                'imageUrl': '',
                'calories': 63.0,
                'carbs': 11.2,
                'protein': 1.4,
                'fat': 0.3,
              });
            },
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
