import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/widgets/bmi_drag_drop.dart';
import '../../../../shared/widgets/smartwatch_linker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Smartwatch connection state
  bool _isWatchConnected = false;
  String? _connectedWatchName;

  // UI state
  bool _isPersonalInfoExpanded = false;

  @override
  void initState() {
    super.initState();
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
        key: const PageStorageKey('profile_scroll'),
        child: Column(
          children: [
            _buildHeader(user),
            const SizedBox(height: AppSizes.md),
            _buildExpandableHealthMetrics(user),
            const SizedBox(height: AppSizes.md),
            _buildExpandablePersonalInfo(user),
            const SizedBox(height: AppSizes.md),
            _buildExpandableBMISection(user),
            const SizedBox(height: AppSizes.md),
            _buildExpandableSmartwatchSection(),
            const SizedBox(height: AppSizes.md),
            _buildExpandablePreferences(user),
            const SizedBox(height: AppSizes.md),
            _buildExpandableActions(),
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

  // Navigate to settings screen for editing profile
  void _showEditProfileDialog(User user) {
    context.push('/profile/edit');
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

  // Expandable sections
  Widget _buildExpandableHealthMetrics(User user) {
    return Container(
      key: const ValueKey('health_metrics_container'),
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [AppShadows.medium],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const PageStorageKey('health_metrics_expansion'),
          leading: Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.favorite, color: AppColors.primary),
          ),
          title: Text(
            'Health Metrics',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'BMI: ${user.bmi.toStringAsFixed(1)} • ${_getBMICategory(user.bmi)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing:
              const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                            'BMI',
                            '${user.bmi.toStringAsFixed(1)}',
                            _getBMICategory(user.bmi)),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: _buildMetricCard(
                            'BMR', '${user.bmr.toInt()}', 'kcal/day'),
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
                        child: _buildMetricCard('Target',
                            '${user.targetCalories.toInt()}', 'kcal/day'),
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

  Widget _buildExpandablePersonalInfo(User user) {
    return Container(
      key: const ValueKey('personal_info_container'),
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [AppShadows.medium],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const PageStorageKey('personal_info_expansion'),
          leading: Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          title: Text(
            'Personal Information',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${user.age}y • ${user.height.toStringAsFixed(0)}cm • ${user.weight.toStringAsFixed(1)}kg',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isPersonalInfoExpanded)
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () {
                    _showEditProfileDialog(user);
                  },
                ),
              Icon(
                _isPersonalInfoExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
            ],
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isPersonalInfoExpanded = expanded;
            });
          },
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: _buildInfoDisplay(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableBMISection(User user) {
    return Container(
      key: const ValueKey('bmi_section_container'),
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [AppShadows.medium],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const PageStorageKey('bmi_section_expansion'),
          leading: Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.monitor_weight, color: AppColors.primary),
          ),
          title: Text(
            'BMI Calculator',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Interactive BMI slider',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing:
              const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: BMIDragDrop(
                initialBMI: user.bmi,
                onBMIChanged: (bmi) {
                  // BMI changed - would update weight if editing
                  // For now, this is just for visualization
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSmartwatchSection() {
    return Container(
      key: const ValueKey('smartwatch_container'),
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [AppShadows.medium],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const PageStorageKey('smartwatch_expansion'),
          leading: Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.watch, color: AppColors.primary),
          ),
          title: Text(
            'Smartwatch Connection',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            _isWatchConnected
                ? 'Connected: $_connectedWatchName'
                : 'Not connected',
            style: AppTextStyles.bodySmall.copyWith(
              color: _isWatchConnected
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
          ),
          trailing:
              const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: SmartwatchLinker(
                isConnected: _isWatchConnected,
                deviceName: _connectedWatchName,
                onConnect: () {
                  setState(() {
                    _isWatchConnected = true;
                    _connectedWatchName = 'Apple Watch Series 9';
                  });
                },
                onDisconnect: () {
                  setState(() {
                    _isWatchConnected = false;
                    _connectedWatchName = null;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandablePreferences(User user) {
    return Container(
      key: const ValueKey('preferences_container'),
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [AppShadows.medium],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const PageStorageKey('preferences_expansion'),
          leading: Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.restaurant, color: AppColors.primary),
          ),
          title: Text(
            'Preferences & Health',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${user.allergies.length} allergies • ${user.foodPreferences.length} preferences',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () {
                  context.push('/health-preferences');
                },
              ),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            ],
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                children: [
                  _buildPreferenceSection(
                      'Allergies', user.allergies, Icons.warning),
                  const SizedBox(height: AppSizes.md),
                  _buildPreferenceSection(
                      'Food Preferences', user.foodPreferences, Icons.favorite),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableActions() {
    return Container(
      key: const ValueKey('actions_container'),
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [AppShadows.medium],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const PageStorageKey('actions_expansion'),
          leading: Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.settings, color: AppColors.primary),
          ),
          title: Text(
            'Settings & Actions',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Preferences, data export, logout',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing:
              const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                children: [
                  _buildActionButton(
                    'App Settings',
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
            ),
          ],
        ),
      ),
    );
  }
}
