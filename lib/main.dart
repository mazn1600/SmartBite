import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'constants/app_theme.dart';
import 'constants/app_constants.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/meal_plan_screen.dart';
import 'screens/food_search_screen.dart';
import 'screens/store_locator_screen.dart';
import 'screens/food_detail_screen.dart';
import 'screens/progress_screen.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/meal_recommendation_service.dart';
import 'services/price_comparison_service.dart';

void main() {
  runApp(const SmartBiteApp());
}

class SmartBiteApp extends StatelessWidget {
  const SmartBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => MealRecommendationService()),
        ChangeNotifierProvider(create: (_) => PriceComparisonService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.md,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
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
  ],
);
