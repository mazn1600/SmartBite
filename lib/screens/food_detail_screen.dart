import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_theme.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodName;
  final String imageUrl;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;

  const FoodDetailScreen({
    super.key,
    required this.foodName,
    required this.imageUrl,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int quantity = 5;
  String servingSize = 'Piece (0.1 oz)';
  String selectedMeal = 'Breakfast';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and favorite
            _buildHeader(),

            // Food image
            _buildFoodImage(),

            // Food details
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFoodTitle(),
                    _buildNutritionalSummary(),
                    _buildQuantitySelectors(),
                    _buildAddToMealButton(),
                    _buildNutritionalFacts(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Add to favorites
            },
            icon: const Icon(
              Icons.favorite_border,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXl),
          bottomRight: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern or gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.lightGreen,
                  AppColors.lightGreen.withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.radiusXl),
                bottomRight: Radius.circular(AppSizes.radiusXl),
              ),
            ),
          ),
          // Food image placeholder
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [AppShadows.medium],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                child: widget.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.fastfood,
                            size: 80,
                            color: AppColors.primary,
                          );
                        },
                      )
                    : Icon(
                        Icons.fastfood,
                        size: 80,
                        color: AppColors.primary,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTitle() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Text(
        widget.foodName,
        style: AppTextStyles.h3.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNutritionalSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNutritionItem('${widget.calories.toInt()} Cal', 'Calories'),
          _buildNutritionItem('${widget.carbs.toStringAsFixed(1)} g', 'Carbs'),
          _buildNutritionItem(
              '${widget.protein.toStringAsFixed(1)} g', 'Protein'),
          _buildNutritionItem('${widget.fat.toStringAsFixed(1)} g', 'Fat'),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
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

  Widget _buildQuantitySelectors() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Row(
        children: [
          Expanded(
            child: _buildSelector(
              'Quantity',
              quantity.toString().padLeft(2, '0'),
              () => _showQuantitySelector(),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _buildSelector(
              'Serving',
              servingSize,
              () => _showServingSelector(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToMealButton() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showMealSelector(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add to $selectedMeal',
                style: AppTextStyles.buttonLarge,
              ),
              const SizedBox(width: AppSizes.sm),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionalFacts() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutritional Facts',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _buildNutritionFactItem('Calories', '${widget.calories.toInt()} Cal'),
          _buildNutritionFactItem(
              'Protein', '${widget.protein.toStringAsFixed(1)} g'),
          _buildNutritionFactItem(
              'Carbohydrates', '${widget.carbs.toStringAsFixed(1)} g'),
          _buildNutritionFactItem('Fat', '${widget.fat.toStringAsFixed(1)} g'),
          _buildNutritionFactItem('Fiber', '2.1 g'),
          _buildNutritionFactItem('Sugar', '0.8 g'),
          _buildNutritionFactItem('Sodium', '180 mg'),
          _buildNutritionFactItem('Potassium', '45 mg'),
        ],
      ),
    );
  }

  Widget _buildNutritionFactItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
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

  void _showQuantitySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Quantity',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: AppSizes.lg),
            Wrap(
              spacing: AppSizes.md,
              children: List.generate(20, (index) {
                final value = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() => quantity = value);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: quantity == value
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(
                        color: quantity == value
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        value.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: quantity == value
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showServingSelector() {
    final servings = [
      'Piece (0.1 oz)',
      'Cup (8 oz)',
      'Slice (1 oz)',
      'Gram (1g)'
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Serving Size',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: AppSizes.lg),
            ...servings.map((serving) => ListTile(
                  title: Text(serving),
                  trailing: serving == servingSize
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => servingSize = serving);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showMealSelector() {
    final meals = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add to Meal',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: AppSizes.lg),
            ...meals.map((meal) => ListTile(
                  title: Text(meal),
                  trailing: meal == selectedMeal
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => selectedMeal = meal);
                    Navigator.pop(context);
                    // TODO: Add food to selected meal
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to $meal'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }
}
