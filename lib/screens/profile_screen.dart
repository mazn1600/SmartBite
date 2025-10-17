import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../widgets/bmi_drag_drop.dart';
import '../widgets/smartwatch_linker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String _selectedGender = 'male';
  String _selectedActivityLevel = 'lightly_active';
  String _selectedGoal = 'weight_loss';

  // Smartwatch connection state
  bool _isWatchConnected = false;
  String? _connectedWatchName;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user != null) {
      _nameController = TextEditingController(text: user.name);
      _ageController = TextEditingController(text: user.age.toString());
      _heightController = TextEditingController(text: user.height.toString());
      _weightController = TextEditingController(text: user.weight.toString());
      _selectedGender = user.gender;
      _selectedActivityLevel = user.activityLevel;
      _selectedGoal = user.goal;
    } else {
      _nameController = TextEditingController();
      _ageController = TextEditingController();
      _heightController = TextEditingController();
      _weightController = TextEditingController();
    }
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
      backgroundColor: AppColors.background,
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.currentUser == null) {
            return _buildLoginPrompt();
          }

          return _buildProfileContent(authService.currentUser!);
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_outline,
            size: 80,
            color: AppColors.grey,
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'Please log in to view your profile',
            style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(User user) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(user),
            _buildHealthMetrics(user),
            _buildBMISection(user),
            _buildSmartwatchSection(),
            _buildPersonalInfo(user),
            _buildPreferences(user),
            _buildActions(),
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXl),
          bottomRight: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
              ),
              Text(
                'Profile',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.white,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            user.name,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user.email,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics(User user) {
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
            'Health Metrics',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('BMI', '$user.bmi.toStringAsFixed(1)',
                    _getBMICategory(user.bmi)),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child:
                    _buildMetricCard('BMR', '${user.bmr.toInt()}', 'kcal/day'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                    'TDEE', '${user.tdee.toInt()}', 'kcal/day'),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _buildMetricCard(
                    'Target', '${user.targetCalories.toInt()}', 'kcal/day'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle) {
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
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMISection(User user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: BMIDragDrop(
        initialBMI: user.bmi,
        onBMIChanged: (bmi) {
          // Update user's weight based on BMI change
          final newWeight = bmi * ((user.height / 100) * (user.height / 100));
          _weightController.text = newWeight.toStringAsFixed(1);
        },
      ),
    );
  }

  Widget _buildSmartwatchSection() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.lg),
      child: SmartwatchLinker(
        isConnected: _isWatchConnected,
        deviceName: _connectedWatchName,
        onConnect: () {
          setState(() {
            _isWatchConnected = true;
            _connectedWatchName = 'Apple Watch Series 9'; // Default for demo
          });
        },
        onDisconnect: () {
          setState(() {
            _isWatchConnected = false;
            _connectedWatchName = null;
          });
        },
      ),
    );
  }

  Widget _buildPersonalInfo(User user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Information',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(
                  _isEditing ? Icons.close : Icons.edit,
                  color: AppColors.primary,
                ),
                tooltip: _isEditing ? 'Close Editing' : 'Edit',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          if (_isEditing) ...[
            _buildEditableForm(),
          ] else ...[
            _buildInfoDisplay(user),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoDisplay(User user) {
    return Column(
      children: [
        _buildInfoRow('Age', '${user.age} years'),
        _buildInfoRow('Height', '${user.height.toStringAsFixed(0)} cm'),
        _buildInfoRow('Weight', '${user.weight.toStringAsFixed(1)} kg'),
        _buildInfoRow('Gender', user.gender.replaceAll('_', ' ').toUpperCase()),
        _buildInfoRow('Activity Level',
            user.activityLevel.replaceAll('_', ' ').toUpperCase()),
        _buildInfoRow('Goal', user.goal.replaceAll('_', ' ').toUpperCase()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(_nameController, 'Name', Icons.person),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(_ageController, 'Age', Icons.cake)),
              const SizedBox(width: AppSizes.md),
              Expanded(
                  child: _buildTextField(
                      _heightController, 'Height (cm)', Icons.height)),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          _buildTextField(
              _weightController, 'Weight (kg)', Icons.monitor_weight),
          const SizedBox(height: AppSizes.md),
          _buildDropdown('Gender', _selectedGender, ['male', 'female'],
              (value) {
            setState(() => _selectedGender = value!);
          }),
          const SizedBox(height: AppSizes.md),
          _buildDropdown('Activity Level', _selectedActivityLevel, [
            'sedentary',
            'lightly_active',
            'moderately_active',
            'very_active',
            'extremely_active'
          ], (value) {
            setState(() => _selectedActivityLevel = value!);
          }),
          const SizedBox(height: AppSizes.md),
          _buildDropdown('Goal', _selectedGoal,
              ['weight_loss', 'weight_gain', 'maintenance'], (value) {
            setState(() => _selectedGoal = value!);
          }),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _isEditing = false);
                    _initializeControllers();
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item.replaceAll('_', ' ').toUpperCase()),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPreferences(User user) {
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
            'Preferences & Health',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          _buildPreferenceSection('Allergies', user.allergies, Icons.warning),
          const SizedBox(height: AppSizes.md),
          _buildPreferenceSection('Health Conditions', user.healthConditions,
              Icons.health_and_safety),
          const SizedBox(height: AppSizes.md),
          _buildPreferenceSection(
              'Food Preferences', user.foodPreferences, Icons.favorite),
        ],
      ),
    );
  }

  Widget _buildPreferenceSection(
      String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSizes.sm),
            Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        if (items.isEmpty)
          Text(
            'None specified',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: items
                .map((item) => Chip(
                      label: Text(item),
                      backgroundColor: AppColors.lightGreen,
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        children: [
          _buildActionButton(
            'Edit Preferences',
            Icons.settings,
            () {
              context.push('/settings');
            },
          ),
          const SizedBox(height: AppSizes.md),
          _buildActionButton(
            'Export Data',
            Icons.download,
            () {
              // TODO: Implement data export
            },
          ),
          const SizedBox(height: AppSizes.md),
          _buildActionButton(
            'Logout',
            Icons.logout,
            () {
              _showLogoutDialog();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed,
      {bool isDestructive = false}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon,
            color: isDestructive ? AppColors.error : AppColors.primary),
        label: Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: isDestructive ? AppColors.error : AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDestructive ? AppColors.error : AppColors.primary,
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
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
        currentIndex: 4, // Profile tab selected
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
              // Add food item
              break;
            case 3:
              context.go('/progress');
              break;
            case 4:
              // Already on profile
              break;
          }
        },
      ),
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser == null) return;

    try {
      final updatedUser = currentUser.copyWith(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        gender: _selectedGender,
        activityLevel: _selectedActivityLevel,
        goal: _selectedGoal,
        updatedAt: DateTime.now(),
      );

      await authService.updateProfile(updatedUser);

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(BuildContext as BuildContext).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(BuildContext as BuildContext).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthService>(context, listen: false).logout();
              context.go('/login');
            },
            child:
                const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
