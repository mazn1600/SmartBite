import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/supabase_auth_service.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      final authService =
          Provider.of<SupabaseAuthService>(context, listen: false);
      final localAuthService = Provider.of<AuthService>(context, listen: false);

      print('DEBUG: Starting Supabase sign in...');
      final result = await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      print('DEBUG: Supabase sign in result: ${result.isSuccess}');

      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        if (result.isSuccess) {
          print('DEBUG: Supabase login successful, attempting local login...');
          // Try to login to local auth for compatibility (optional)
          bool localLoginSuccess = false;
          try {
            localLoginSuccess = await localAuthService.login(
              _emailController.text.trim(),
              _passwordController.text,
            );
            print('DEBUG: Local login successful');
          } catch (e) {
            // Local login failed - user doesn't exist locally
            print(
                'DEBUG: Local auth login failed, will create temporary user: $e');
          }

          // If local login failed, create a temporary user for the home screen
          if (!localLoginSuccess && result.data?.user != null) {
            print('DEBUG: Creating temporary local user from Supabase data...');
            try {
              final supabaseUser = result.data!.user!;
              final metadata = supabaseUser.userMetadata ?? {};

              // Register user in local storage with Supabase data
              await localAuthService.register(
                email: supabaseUser.email ?? _emailController.text.trim(),
                password: _passwordController.text,
                name: metadata['first_name']?.toString() ?? 'User',
                age: metadata['age'] as int? ?? 25,
                height: (metadata['height'] as num?)?.toDouble() ?? 170.0,
                weight: (metadata['weight'] as num?)?.toDouble() ?? 70.0,
                gender: metadata['gender']?.toString() ?? 'male',
                activityLevel: metadata['activity_level']?.toString() ??
                    'moderately_active',
                goal: metadata['goal']?.toString() ?? 'maintenance',
              );
              print('DEBUG: Temporary user created successfully');
            } catch (e) {
              print('DEBUG: Failed to create temporary user: $e');
            }
          }

          print('DEBUG: Navigating to home...');
          // Navigate to home regardless of local auth status
          // Use pushReplacement to ensure clean navigation
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              context.pushReplacement('/home');
              print('DEBUG: Navigation executed!');
            }
          });
        } else {
          print('DEBUG: Login failed with error: ${result.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ??
                  'Login failed. Please check your credentials.'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Exception during login: $e');
      // Hide loading dialog if still showing
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final authService =
        Provider.of<SupabaseAuthService>(context, listen: false);

    final result = await authService.signInWithGoogle();

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Redirecting to Google sign in...'),
            backgroundColor: AppColors.info,
            duration: Duration(seconds: 2),
          ),
        );
        // OAuth will handle the redirect
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Google sign in failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _signInWithApple() async {
    final authService =
        Provider.of<SupabaseAuthService>(context, listen: false);

    final result = await authService.signInWithApple();

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Redirecting to Apple sign in...'),
            backgroundColor: AppColors.info,
            duration: Duration(seconds: 2),
          ),
        );
        // OAuth will handle the redirect
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Apple sign in failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authService =
        Provider.of<SupabaseAuthService>(context, listen: false);

    final result = await authService.resetPassword(email);

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to send reset email'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.xxl),

                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLg),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Text(
                        'Welcome Back',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'Sign in to continue your nutrition journey',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.xxl),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) => Validators.email(value),
                ),

                const SizedBox(height: AppSizes.lg),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) => Validators.password(value),
                ),

                const SizedBox(height: AppSizes.md),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // Login Button
                Consumer<SupabaseAuthService>(
                  builder: (context, authService, child) {
                    return ElevatedButton(
                      onPressed: authService.isLoading ? null : _login,
                      child: authService.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white),
                              ),
                            )
                          : const Text('Sign In'),
                    );
                  },
                ),

                const SizedBox(height: AppSizes.lg),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: Text(
                        'OR',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: AppSizes.lg),

                // Social Login Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text('Google'),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: AppSizes.md),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _signInWithApple,
                        icon: const Icon(Icons.apple, size: 24),
                        label: const Text('Apple'),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: AppSizes.md),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xl),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
