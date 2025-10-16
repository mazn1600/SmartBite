import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class FoodSearchScreen extends StatelessWidget {
  const FoodSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Search'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'Food Search',
              style: AppTextStyles.h2,
            ),
            SizedBox(height: AppSizes.md),
            Text(
              'Comprehensive food database coming soon',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
