import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';
import '../models/food.dart';
import '../services/meal_recommendation_service.dart';
import '../widgets/food_image_picker.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameArabicController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _recipeInstructionsController = TextEditingController();

  String _selectedCategory = AppConstants.foodCategories.first;
  List<String> _selectedAllergens = [];
  List<String> _selectedTags = [];
  String? _selectedImagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _nameArabicController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _preparationTimeController.dispose();
    _servingsController.dispose();
    _recipeInstructionsController.dispose();
    super.dispose();
  }

  void _addFood() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final mealService =
          Provider.of<MealRecommendationService>(context, listen: false);

      final food = Food(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        nameArabic: _nameArabicController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        caloriesPer100g: double.parse(_caloriesController.text),
        proteinPer100g: double.parse(_proteinController.text),
        carbsPer100g: double.parse(_carbsController.text),
        fatPer100g: double.parse(_fatController.text),
        fiberPer100g: double.parse(_fiberController.text),
        sugarPer100g: double.parse(_sugarController.text),
        sodiumPer100g: double.parse(_sodiumController.text),
        allergens: _selectedAllergens,
        imageUrl: _selectedImagePath ?? '',
        recipeInstructions: _recipeInstructionsController.text.trim(),
        preparationTime: int.parse(_preparationTimeController.text),
        servings: int.parse(_servingsController.text),
        tags: _selectedTags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add food to the service
      mealService.addFood(food);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding food: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          TextButton(
            onPressed: _addFood,
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Image
              FoodImagePicker(
                initialImagePath: _selectedImagePath,
                onImageSelected: (imagePath) {
                  setState(() {
                    _selectedImagePath = imagePath;
                  });
                },
                label: 'Food Photo',
                isRequired: false,
              ),
              const SizedBox(height: AppSizes.xl),

              // Basic Information
              Text(
                'Basic Information',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.lg),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name (English)',
                  hintText: 'e.g., Grilled Chicken Breast',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Food name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.lg),

              // Name Arabic
              TextFormField(
                controller: _nameArabicController,
                decoration: const InputDecoration(
                  labelText: 'Food Name (Arabic)',
                  hintText: 'e.g., صدر دجاج مشوي',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Arabic name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.lg),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: AppConstants.foodCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_getCategoryDisplayName(category)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: AppSizes.lg),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of the food',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.xl),

              // Nutritional Information
              Text(
                'Nutritional Information (per 100g)',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.lg),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Calories',
                        suffixText: 'kcal',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Protein',
                        suffixText: 'g',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Carbs',
                        suffixText: 'g',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fat',
                        suffixText: 'g',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fiberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fiber',
                        suffixText: 'g',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: TextFormField(
                      controller: _sugarController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sugar',
                        suffixText: 'g',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              TextFormField(
                controller: _sodiumController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sodium',
                  suffixText: 'mg',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.xl),

              // Preparation Details
              Text(
                'Preparation Details',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.lg),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _preparationTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prep Time',
                        suffixText: 'minutes',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: TextFormField(
                      controller: _servingsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Servings',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // Recipe Instructions
              TextFormField(
                controller: _recipeInstructionsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Recipe Instructions',
                  hintText: 'Step-by-step cooking instructions',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Recipe instructions are required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.xl),

              // Allergens
              Text(
                'Allergens (Optional)',
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: AppConstants.commonAllergens.map((allergen) {
                  final isSelected = _selectedAllergens.contains(allergen);
                  return FilterChip(
                    label: Text(allergen.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAllergens.add(allergen);
                        } else {
                          _selectedAllergens.remove(allergen);
                        }
                      });
                    },
                    selectedColor: AppColors.warning.withOpacity(0.2),
                    checkmarkColor: AppColors.warning,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.xl),

              // Tags
              Text(
                'Tags (Optional)',
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: [
                  'high-protein',
                  'low-carb',
                  'low-fat',
                  'high-fiber',
                  'gluten-free',
                  'dairy-free',
                  'vegan',
                  'vegetarian',
                  'quick-prep',
                  'healthy',
                ].map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.xl),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addFood,
                  child: const Text('Add Food'),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'proteins':
        return 'Proteins';
      case 'carbohydrates':
        return 'Carbohydrates';
      case 'vegetables':
        return 'Vegetables';
      case 'fruits':
        return 'Fruits';
      case 'dairy':
        return 'Dairy';
      case 'grains':
        return 'Grains';
      case 'nuts_seeds':
        return 'Nuts & Seeds';
      case 'beverages':
        return 'Beverages';
      case 'snacks':
        return 'Snacks';
      case 'desserts':
        return 'Desserts';
      default:
        return category;
    }
  }
}
