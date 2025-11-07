import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../auth/services/auth_service.dart';
import '../../../../shared/models/user.dart';

class HealthPreferencesScreen extends StatefulWidget {
  const HealthPreferencesScreen({super.key});

  @override
  State<HealthPreferencesScreen> createState() =>
      _HealthPreferencesScreenState();
}

class _HealthPreferencesScreenState extends State<HealthPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _targetWeightController = TextEditingController();

  // Form data
  List<String> selectedAllergies = [];
  List<String> selectedFoodPreferences = [];
  List<String> selectedDietaryPreferences = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user != null) {
      _targetWeightController.text = user.targetWeight?.toString() ?? '';
      selectedAllergies = List.from(user.allergies);

      // Separate food preferences from dietary preferences
      selectedFoodPreferences = user.foodPreferences
          .where((pref) => AppConstants.foodCategories.contains(pref))
          .toList();
      selectedDietaryPreferences = user.foodPreferences
          .where((pref) => AppConstants.dietaryPreferences.contains(pref))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Preferences'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.currentUser == null) {
            return const Center(
              child: Text('Please log in to view health preferences'),
            );
          }

          return _buildContent(authService.currentUser!);
        },
      ),
    );
  }

  Widget _buildContent(User user) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Health & Dietary Preferences',
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Customize your meal recommendations based on your health needs and preferences',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.xl),

            // Target Weight Section
            _buildTargetWeightSection(user),

            const SizedBox(height: AppSizes.xl),

            // Allergies Section
            _buildAllergiesSection(),

            const SizedBox(height: AppSizes.xl),

            // Food Preferences Section
            _buildFoodPreferencesSection(),

            const SizedBox(height: AppSizes.xl),

            // Dietary Preferences Section
            _buildDietaryPreferencesSection(),

            const SizedBox(height: AppSizes.xl),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: const Text(
                  'Save Preferences',
                  style: AppTextStyles.buttonLarge,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetWeightSection(User user) {
    return Container(
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
            'Target Weight',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Set your target weight for personalized meal planning',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.lg),
          TextFormField(
            controller: _targetWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target Weight',
              hintText: 'e.g., 70',
              prefixIcon: Icon(Icons.flag_outlined),
              suffixText: 'kg',
              helperText:
                  'Optional: Leave empty if you don\'t have a specific target',
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final targetWeight = double.tryParse(value);
                if (targetWeight == null ||
                    targetWeight < 20 ||
                    targetWeight > 300) {
                  return 'Please enter a valid target weight (20-300 kg)';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return Container(
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
            'Food Allergies',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Select foods you are allergic to (we\'ll avoid these in recommendations)',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.lg),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: AppConstants.commonAllergens.map((allergen) {
              final isSelected = selectedAllergies.contains(allergen);
              return FilterChip(
                label: Text(allergen.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedAllergies.add(allergen);
                    } else {
                      selectedAllergies.remove(allergen);
                    }
                  });
                },
                selectedColor: AppColors.warning.withOpacity(0.2),
                checkmarkColor: AppColors.warning,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodPreferencesSection() {
    return Container(
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
            'Food Categories',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Select food categories you prefer to include in your meals',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.lg),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: AppConstants.foodCategories.map((category) {
              final isSelected = selectedFoodPreferences.contains(category);
              return FilterChip(
                label: Text(_getFoodCategoryDisplayName(category)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedFoodPreferences.add(category);
                    } else {
                      selectedFoodPreferences.remove(category);
                    }
                  });
                },
                selectedColor: AppColors.success.withOpacity(0.2),
                checkmarkColor: AppColors.success,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryPreferencesSection() {
    return Container(
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
            'Dietary Preferences',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Select your dietary lifestyle and preferences',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.lg),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: AppConstants.dietaryPreferences.map((preference) {
              final isSelected =
                  selectedDietaryPreferences.contains(preference);
              return FilterChip(
                label: Text(_getDietaryPreferenceDisplayName(preference)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedDietaryPreferences.add(preference);
                    } else {
                      selectedDietaryPreferences.remove(preference);
                    }
                  });
                },
                selectedColor: AppColors.info.withOpacity(0.2),
                checkmarkColor: AppColors.info,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser == null) return;

    try {
      // Create updated user with new preferences
      final updatedUser = currentUser.copyWith(
        targetWeight: _targetWeightController.text.isNotEmpty
            ? double.tryParse(_targetWeightController.text)
            : null,
        allergies: selectedAllergies,
        foodPreferences: [
          ...selectedFoodPreferences,
          ...selectedDietaryPreferences
        ],
        updatedAt: DateTime.now(),
      );

      // Update user profile
      await authService.updateProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health preferences saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save preferences: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Helper methods for display names
  String _getFoodCategoryDisplayName(String category) {
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

  String _getDietaryPreferenceDisplayName(String preference) {
    switch (preference) {
      case 'vegetarian':
        return 'Vegetarian';
      case 'vegan':
        return 'Vegan';
      case 'halal':
        return 'Halal';
      case 'low_carb':
        return 'Low-Carb';
      case 'high_protein':
        return 'High-Protein';
      case 'keto':
        return 'Keto';
      case 'paleo':
        return 'Paleo';
      case 'mediterranean':
        return 'Mediterranean';
      case 'gluten_free':
        return 'Gluten-Free';
      case 'dairy_free':
        return 'Dairy-Free';
      default:
        return preference;
    }
  }
}
