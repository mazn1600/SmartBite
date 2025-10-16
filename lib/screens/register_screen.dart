import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/bmi_drag_drop.dart';
import '../widgets/smartwatch_linker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Form data
  String _selectedGender = AppConstants.genders.first;
  String _selectedActivityLevel = AppConstants.activityLevels.first;
  String _selectedGoal = AppConstants.goals.first;
  List<String> _selectedAllergies = [];
  List<String> _selectedHealthConditions = [];
  List<String> _selectedFoodPreferences = [];

  // BMI and Smartwatch data
  double? _bmiFromInBody;
  bool _isWatchConnected = false;
  String? _connectedWatchName;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final databaseService = DatabaseService();

    // Validate health data
    final isValidHealthData = await databaseService.validateHealthData(
      age: int.parse(_ageController.text),
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      gender: _selectedGender,
    );

    if (!isValidHealthData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid health data'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if email exists
    final emailExists =
        await databaseService.emailExists(_emailController.text.trim());
    if (emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email already exists'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      gender: _selectedGender,
      activityLevel: _selectedActivityLevel,
      goal: _selectedGoal,
      allergies: _selectedAllergies,
      healthConditions: _selectedHealthConditions,
      foodPreferences: _selectedFoodPreferences,
    );

    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.error ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of $_totalSteps'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentStep = index;
            });
          },
          children: [
            _buildBasicInfoStep(),
            _buildHealthInfoStep(),
            _buildPreferencesStep(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: const Text('Previous'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: AppSizes.md),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextStep,
                child: Text(_currentStep == _totalSteps - 1
                    ? 'Create Account'
                    : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Let\'s start with your basic details',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.xl),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              return authService.validateEmail(value ?? '');
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            validator: (value) {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              return authService.validatePassword(value ?? '');
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Confirm your password',
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: (value) {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              return authService.validateName(value ?? '');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Information',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Help us personalize your nutrition plan',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.xl),

          // Age Field
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              hintText: 'Enter your age',
              prefixIcon: Icon(Icons.cake_outlined),
              suffixText: 'years',
            ),
            validator: (value) {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              return authService.validateAge(int.tryParse(value ?? '') ?? 0);
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Height Field
          TextFormField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Height',
              hintText: 'Enter your height',
              prefixIcon: Icon(Icons.height),
              suffixText: 'cm',
            ),
            validator: (value) {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              return authService
                  .validateHeight(double.tryParse(value ?? '') ?? 0);
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Weight Field
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight',
              hintText: 'Enter your weight',
              prefixIcon: Icon(Icons.monitor_weight_outlined),
              suffixText: 'kg',
            ),
            validator: (value) {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              return authService
                  .validateWeight(double.tryParse(value ?? '') ?? 0);
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Gender Selection
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            items: AppConstants.genders.map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Activity Level Selection
          DropdownButtonFormField<String>(
            value: _selectedActivityLevel,
            decoration: const InputDecoration(
              labelText: 'Activity Level',
              prefixIcon: Icon(Icons.fitness_center),
            ),
            items: AppConstants.activityLevels.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(_getActivityLevelDisplayName(level)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedActivityLevel = value!;
              });
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Goal Selection
          DropdownButtonFormField<String>(
            value: _selectedGoal,
            decoration: const InputDecoration(
              labelText: 'Health Goal',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: AppConstants.goals.map((goal) {
              return DropdownMenuItem(
                value: goal,
                child: Text(_getGoalDisplayName(goal)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGoal = value!;
              });
            },
          ),
          const SizedBox(height: AppSizes.xl),

          // BMI Drag and Drop Section
          BMIDragDrop(
            initialBMI: _bmiFromInBody,
            onBMIChanged: (bmi) {
              setState(() {
                _bmiFromInBody = bmi;
              });
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // InBody Data Source (for demonstration)
          if (_bmiFromInBody == null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sample InBody Data:',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                InBodyDataSource(
                  data: 'BMI: 23.5, Body Fat: 15.2%, Muscle Mass: 45.3kg',
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
          ],

          // Smartwatch Connection Section
          SmartwatchLinker(
            isConnected: _isWatchConnected,
            deviceName: _connectedWatchName,
            onConnect: () {
              setState(() {
                _isWatchConnected = true;
                _connectedWatchName =
                    'Apple Watch Series 9'; // Default for demo
              });
            },
            onDisconnect: () {
              setState(() {
                _isWatchConnected = false;
                _connectedWatchName = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences & Restrictions',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Help us customize your meal recommendations',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.xl),

          // Health Conditions
          Text(
            'Health Conditions (Optional)',
            style:
                AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: AppConstants.healthConditions.map((condition) {
              final isSelected = _selectedHealthConditions.contains(condition);
              return FilterChip(
                label: Text(_getHealthConditionDisplayName(condition)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedHealthConditions.add(condition);
                    } else {
                      _selectedHealthConditions.remove(condition);
                    }
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.lg),

          // Allergies
          Text(
            'Allergies (Optional)',
            style:
                AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: AppConstants.commonAllergens.map((allergen) {
              final isSelected = _selectedAllergies.contains(allergen);
              return FilterChip(
                label: Text(allergen.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAllergies.add(allergen);
                    } else {
                      _selectedAllergies.remove(allergen);
                    }
                  });
                },
                selectedColor: AppColors.warning.withOpacity(0.2),
                checkmarkColor: AppColors.warning,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.lg),

          // Food Preferences
          Text(
            'Food Preferences (Optional)',
            style:
                AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: AppConstants.foodCategories.map((category) {
              final isSelected = _selectedFoodPreferences.contains(category);
              return FilterChip(
                label: Text(_getFoodCategoryDisplayName(category)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFoodPreferences.add(category);
                    } else {
                      _selectedFoodPreferences.remove(category);
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

  String _getActivityLevelDisplayName(String level) {
    switch (level) {
      case 'sedentary':
        return 'Sedentary (Little to no exercise)';
      case 'lightly_active':
        return 'Lightly Active (Light exercise 1-3 days/week)';
      case 'moderately_active':
        return 'Moderately Active (Moderate exercise 3-5 days/week)';
      case 'very_active':
        return 'Very Active (Hard exercise 6-7 days/week)';
      case 'extremely_active':
        return 'Extremely Active (Very hard exercise, physical job)';
      default:
        return level;
    }
  }

  String _getGoalDisplayName(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Weight Loss';
      case 'weight_gain':
        return 'Weight Gain';
      case 'maintenance':
        return 'Weight Maintenance';
      default:
        return goal;
    }
  }

  String _getHealthConditionDisplayName(String condition) {
    switch (condition) {
      case 'diabetes':
        return 'Diabetes';
      case 'hypertension':
        return 'High Blood Pressure';
      case 'heart_disease':
        return 'Heart Disease';
      case 'celiac_disease':
        return 'Celiac Disease';
      case 'lactose_intolerance':
        return 'Lactose Intolerance';
      case 'kidney_disease':
        return 'Kidney Disease';
      case 'liver_disease':
        return 'Liver Disease';
      default:
        return condition;
    }
  }

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
}
