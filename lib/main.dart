import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/health_preferences_screen.dart';
import 'features/meal_planning/screens/meal_plan_screen.dart';
import 'features/food/screens/food_search_screen.dart';
import 'features/store/screens/store_locator_screen.dart';
import 'features/food/screens/food_detail_screen.dart';
import 'features/food/screens/scan_meal_screen.dart';
import 'features/food/screens/barcode_scan_screen.dart';
import 'features/voice/screens/voice_log_screen.dart';
import 'features/progress/screens/progress_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/meal_planning/services/meal_plan_service.dart';
import 'shared/services/database_service.dart';
import 'features/profile/services/user_service.dart';
import 'features/meal_planning/services/meal_recommendation_service.dart';
import 'features/store/services/price_comparison_service.dart';
import 'features/profile/screens/settings_screen.dart';
import 'features/profile/screens/profile_edit_screen.dart';
import 'features/food/screens/add_food_screen.dart';
import 'core/config/supabase_config.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Disable glow effect and keep native scrolling
    return child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with error handling
  try {
    print('🔌 Initializing Supabase connection...');
    await SupabaseConfig.initialize();
    print('✅ Supabase initialized successfully');

    // Test connection
    final client = SupabaseConfig.client;
    try {
      final session = client.auth.currentSession;
      if (session != null) {
        print('✅ Supabase connection test successful (session found)');
      } else {
        print('✅ Supabase connection test successful (no active session)');
      }
    } catch (e) {
      print('⚠️  Supabase connection test warning: $e');
    }
  } catch (e, stackTrace) {
    print('❌ Failed to initialize Supabase: $e');
    print('Stack trace: $stackTrace');
    // Continue anyway - the app might work with cached data
  }

  // Initialize local database
  try {
    final databaseService = DatabaseService();
    await databaseService.connect();
    print('✅ Local database connected');
  } catch (e) {
    print('⚠️  Local database connection warning: $e');
  }

  runApp(const SmartBiteApp());
}

class SmartBiteApp extends StatelessWidget {
  const SmartBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => MealPlanService()),
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
            scrollBehavior: AppScrollBehavior(),
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
      path: '/profile/edit',
      builder: (context, state) => const ProfileEditScreen(),
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
