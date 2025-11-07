import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_theme.dart';
import '../../auth/services/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  String _selectedGender = 'male';
  String _selectedActivityLevel = 'lightly_active';
  String _selectedGoal = 'weight_loss';

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController = TextEditingController(text: (user?.age ?? 21).toString());
    _heightController =
        TextEditingController(text: (user?.height ?? 170).toString());
    _weightController =
        TextEditingController(text: (user?.weight ?? 70).toString());

    _selectedGender = user?.gender ?? 'male';
    _selectedActivityLevel = user?.activityLevel ?? 'lightly_active';
    _selectedGoal = user?.goal ?? 'weight_loss';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Personal Information'),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _ageController,
                        label: 'Age',
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final age = int.tryParse(value ?? '');
                          if (age == null || age < 1 || age > 120) {
                            return 'Enter a valid age (1-120)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: _buildTextField(
                        controller: _heightController,
                        label: 'Height (cm)',
                        icon: Icons.height,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final height = double.tryParse(value ?? '');
                          if (height == null || height < 50 || height > 300) {
                            return 'Valid range: 50-300 cm';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                _buildTextField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  icon: Icons.monitor_weight,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final weight = double.tryParse(value ?? '');
                    if (weight == null || weight < 20 || weight > 500) {
                      return 'Valid range: 20-500 kg';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                _buildDropdown(
                  label: 'Gender',
                  value: _selectedGender,
                  items: const ['male', 'female'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedGender = value);
                    }
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                _buildDropdown(
                  label: 'Activity Level',
                  value: _selectedActivityLevel,
                  items: const [
                    'sedentary',
                    'lightly_active',
                    'moderately_active',
                    'very_active',
                    'extremely_active',
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedActivityLevel = value);
                    }
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                _buildDropdown(
                  label: 'Goal',
                  value: _selectedGoal,
                  items: const ['weight_loss', 'weight_gain', 'maintenance'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedGoal = value);
                    }
                  },
                ),
                const SizedBox(height: AppSizes.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item.replaceAll('_', ' ').toUpperCase()),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No user found. Please log in again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (age == null || height == null || weight == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numeric values.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        age: age,
        height: height,
        weight: weight,
        gender: _selectedGender,
        activityLevel: _selectedActivityLevel,
        goal: _selectedGoal,
        updatedAt: DateTime.now(),
      );

      await authService.updateProfile(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
