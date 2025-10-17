import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class ScanMealScreen extends StatelessWidget {
  const ScanMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Meal'),
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt, size: 64, color: AppColors.primary),
              const SizedBox(height: AppSizes.md),
              Text(
                'Camera-based meal scanning coming soon',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.lg),
              ElevatedButton(
                onPressed: () {
                  // Placeholder action to simulate a result
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Scanning not implemented yet')),
                  );
                },
                child: const Text('Try demo'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
