import 'package:go_router/go_router.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/health_preferences_screen.dart';
import '../../features/meal_planning/screens/meal_plan_screen.dart';
import '../../features/food/screens/food_search_screen.dart';
import '../../features/store/screens/store_locator_screen.dart';
import '../../features/food/screens/food_detail_screen.dart';
import '../../features/food/screens/scan_meal_screen.dart';
import '../../features/food/screens/barcode_scan_screen.dart';
import '../../features/voice/screens/voice_log_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/food/screens/add_food_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';

/// Application routing configuration
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/health-preferences',
      builder: (context, state) => const HealthPreferencesScreen(),
    ),
    GoRoute(
      path: '/meal-plan',
      builder: (context, state) => const MealPlanScreen(),
    ),
    GoRoute(
      path: '/food-search',
      builder: (context, state) => const FoodSearchScreen(),
    ),
    GoRoute(
      path: '/store-locator',
      builder: (context, state) => const StoreLocatorScreen(),
    ),
    GoRoute(
      path: '/food-detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return FoodDetailScreen(
          foodName: extra?['foodName'] ?? 'Grilled Chicken Salad',
          imageUrl: extra?['imageUrl'] ?? '',
          calories: extra?['calories'] ?? 63.0,
          carbs: extra?['carbs'] ?? 11.2,
          protein: extra?['protein'] ?? 1.4,
          fat: extra?['fat'] ?? 0.3,
        );
      },
    ),
    GoRoute(
      path: '/progress',
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/scan-meal',
      builder: (context, state) => const ScanMealScreen(),
    ),
    GoRoute(
      path: '/barcode-scan',
      builder: (context, state) => const BarcodeScanScreen(),
    ),
    GoRoute(
      path: '/voice-log',
      builder: (context, state) => const VoiceLogScreen(),
    ),
    GoRoute(
      path: '/add-food',
      builder: (context, state) => const AddFoodScreen(),
    ),
  ],
);
