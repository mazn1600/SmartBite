import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/widgets/macro_nutrient_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/water_intake_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/activity_feed_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int waterGlasses = 3; // TODO: Load from storage/service
  double caloriesConsumed = 1200.0; // TODO: Load from meal plan service
  double caloriesTarget = 2000.0; // TODO: Load from user profile
  double caloriesBurned = 500.0; // TODO: Load from health service

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    // TODO: Load real data from services
    // - Load today's calories from meal plan service
    // - Load calories burned from health service
    // - Load water intake from storage
    // - Load recent activity from Supabase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final isAuthenticated = authService.isAuthenticated;

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
    final progressPercentage =
        (caloriesConsumed / caloriesTarget).clamp(0.0, 1.0);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh dashboard data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.md),

              // Welcome Header
              _buildWelcomeHeader(user),

              const SizedBox(height: AppSizes.lg),

              // Today's Progress Card
              ProgressCard(
                caloriesConsumed: caloriesConsumed,
                caloriesTarget: caloriesTarget,
                caloriesBurned: caloriesBurned,
                progressPercentage: progressPercentage,
              ),

              const SizedBox(height: AppSizes.lg),

              // Quick Stats Grid
              _buildQuickStatsGrid(),

              const SizedBox(height: AppSizes.lg),

              // Water Intake
              WaterIntakeWidget(
                currentGlasses: waterGlasses,
                targetGlasses: 8,
                onAddGlass: () {
                  setState(() {
                    if (waterGlasses < 8) {
                      waterGlasses++;
                      // TODO: Save to storage/service
                    }
                  });
                },
              ),

              const SizedBox(height: AppSizes.lg),

              // Macronutrient Breakdown
              _buildMacroNutrientBreakdown(),

              const SizedBox(height: AppSizes.lg),

              // Quick Actions
              const QuickActionsWidget(),

              const SizedBox(height: AppSizes.lg),

              // Recent Activity
              ActivityFeedWidget(
                activities: [
                  // TODO: Load from Supabase
                  ActivityItem(
                    title: 'Breakfast logged',
                    subtitle: 'Scrambled eggs with toast',
                    time: '2h ago',
                    icon: Icons.restaurant,
                    color: AppColors.primary,
                  ),
                  ActivityItem(
                    title: 'Lunch logged',
                    subtitle: 'Grilled chicken salad',
                    time: '5h ago',
                    icon: Icons.restaurant,
                    color: AppColors.success,
                  ),
                ],
              ),

              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    final caloriesRemaining =
        (caloriesTarget - caloriesConsumed).clamp(0.0, double.infinity);

    return Row(
      children: [
        Expanded(
          child: QuickStatsCard(
            title: 'Calories Remaining',
            value: '${caloriesRemaining.toInt()}',
            subtitle: 'kcal left',
            icon: Icons.local_fire_department,
            color: AppColors.accent,
            onTap: () => context.go('/meal-plan'),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: QuickStatsCard(
            title: 'Meals Logged',
            value: '3',
            subtitle: 'today',
            icon: Icons.restaurant_menu,
            color: AppColors.primary,
            onTap: () => context.go('/meal-plan'),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(User user) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Row(
      children: [
        // Profile picture (tap to open profile)
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
              boxShadow: const [AppShadows.small],
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        // Greeting and date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                user.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Notification icon
        IconButton(
          onPressed: () {
            // TODO: Navigate to notifications
          },
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroNutrientBreakdown() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [AppShadows.small],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macronutrients',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const MacroNutrientGrid(
            carbs: 160,
            carbsTarget: 225,
            protein: 80,
            proteinTarget: 112,
            fats: 35,
            fatsTarget: 50,
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
