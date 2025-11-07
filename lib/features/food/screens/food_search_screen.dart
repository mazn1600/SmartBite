import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../meal_planning/services/meal_plan_service.dart';
import '../../../../shared/models/meal_food.dart';
import '../../../../shared/widgets/form_widgets.dart';
import '../../../../shared/utils/error_handler.dart';
import '../../../../shared/widgets/app_refresh_wrapper.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _sortBy = 'name';
  bool _isLoading = false;
  List<MealFood> _filteredFoods = [];
  List<MealFood> _allFoods = [];
  List<String> _categories = ['All'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final mealPlanService =
          Provider.of<MealPlanService>(context, listen: false);
      final categoriesResult = await mealPlanService.getMealFoodCategories();

      if (categoriesResult.isSuccess) {
        setState(() {
          _categories = ['All', ...categoriesResult.data!];
          _allFoods = mealPlanService.mealFoods;
          _filteredFoods = _allFoods;
        });
      } else {
        ErrorHandler.showErrorSnackBar(context, categoriesResult.error!);
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
          context, 'Error loading foods: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterFoods() {
    setState(() {
      _filteredFoods = _allFoods.where((food) {
        final matchesSearch = _searchController.text.isEmpty ||
            food.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            food.category
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesCategory =
            _selectedCategory == 'All' || food.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();

      // Sort foods
      _filteredFoods.sort((a, b) {
        switch (_sortBy) {
          case 'name':
            return a.name.compareTo(b.name);
          case 'calories':
            return a.calories.compareTo(b.calories);
          case 'protein':
            return b.protein.compareTo(a.protein);
          case 'category':
            return a.category.compareTo(b.category);
          default:
            return a.name.compareTo(b.name);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Search'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFoods.isEmpty
                    ? _buildEmptyState()
                    : AppRefreshWrapper(
                        onRefresh: () async {
                          debugPrint('🔁 Refreshing food list...');
                          await _loadFoods();
                        },
                        child: _buildFoodList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusLg),
          bottomRight: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          SmartBiteTextFormField(
            fieldName: 'search',
            label: 'Search foods',
            hintText: 'Search foods...',
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            onChanged: (_) => _filterFoods(),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.primary),
                    onPressed: () {
                      _searchController.clear();
                      _filterFoods();
                    },
                  )
                : null,
          ),
          const SizedBox(height: AppSizes.md),

          // Filters row
          Row(
            children: [
              // Category filter
              Expanded(
                child: SmartBiteDropdownFormField<String>(
                  fieldName: 'category',
                  label: 'Category',
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    _filterFoods();
                  },
                ),
              ),
              const SizedBox(width: AppSizes.md),

              // Sort filter
              Expanded(
                child: SmartBiteDropdownFormField<String>(
                  fieldName: 'sort',
                  label: 'Sort by',
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(
                        value: 'calories', child: Text('Calories')),
                    DropdownMenuItem(value: 'protein', child: Text('Protein')),
                    DropdownMenuItem(
                        value: 'category', child: Text('Category')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    _filterFoods();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.grey,
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'No foods found',
            style: AppTextStyles.h3.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList() {
    return ListView.builder(
      key: const PageStorageKey<String>('food_search_list'),
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: _filteredFoods.length,
      itemBuilder: (context, index) {
        final food = _filteredFoods[index];
        return _buildFoodCard(food);
      },
    );
  }

  Widget _buildFoodCard(MealFood food) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: InkWell(
        onTap: () => _showFoodDetails(food),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              // Food image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: food.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        child: Image.network(
                          food.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.fastfood,
                            color: AppColors.grey,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.fastfood,
                        color: AppColors.grey,
                      ),
              ),
              const SizedBox(width: AppSizes.md),

              // Food details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: AppTextStyles.h6,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      food.category,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      '${food.calories} cal per ${food.servingSize}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Nutrition info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildNutritionChip('P', food.protein.toStringAsFixed(1)),
                  const SizedBox(height: AppSizes.xs),
                  _buildNutritionChip('C', food.carbs.toStringAsFixed(1)),
                  const SizedBox(height: AppSizes.xs),
                  _buildNutritionChip('F', food.fat.toStringAsFixed(1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        '$label: $value',
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showFoodDetails(MealFood food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFoodDetailsSheet(food),
    );
  }

  Widget _buildFoodDetailsSheet(MealFood food) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLg),
          topRight: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Food details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food image and basic info
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: food.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                                child: Image.network(
                                  food.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.fastfood,
                                    color: AppColors.grey,
                                    size: 40,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.fastfood,
                                color: AppColors.grey,
                                size: 40,
                              ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.name,
                              style: AppTextStyles.h4,
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Text(
                              food.category,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Text(
                              '${food.calories} calories per ${food.servingSize}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Nutrition facts
                  Text(
                    'Nutrition Facts',
                    style: AppTextStyles.h5,
                  ),
                  const SizedBox(height: AppSizes.md),

                  _buildNutritionRow('Calories', '${food.calories} cal'),
                  _buildNutritionRow(
                      'Protein', '${food.protein.toStringAsFixed(1)} g'),
                  _buildNutritionRow(
                      'Carbohydrates', '${food.carbs.toStringAsFixed(1)} g'),
                  _buildNutritionRow('Fat', '${food.fat.toStringAsFixed(1)} g'),
                  _buildNutritionRow(
                      'Fiber', '${food.fiber.toStringAsFixed(1)} g'),
                  _buildNutritionRow(
                      'Sugar', '${food.sugar.toStringAsFixed(1)} g'),
                  _buildNutritionRow(
                      'Sodium', '${food.sodium.toStringAsFixed(1)} mg'),

                  const SizedBox(height: AppSizes.lg),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _addToMealPlan(food),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.md),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          child: const Text('Add to Meal Plan'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _viewPrices(food),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.md),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          child: const Text('View Prices'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _addToMealPlan(MealFood food) {
    Navigator.pop(context);
    // TODO: Implement add to meal plan functionality
    ErrorHandler.showInfoSnackBar(
        context, 'Add to meal plan functionality coming soon');
  }

  void _viewPrices(MealFood food) {
    Navigator.pop(context);
    // TODO: Implement view prices functionality
    ErrorHandler.showInfoSnackBar(
        context, 'Price comparison functionality coming soon');
  }
}
