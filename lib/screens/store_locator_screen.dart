import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class StoreLocatorScreen extends StatelessWidget {
  const StoreLocatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Locator'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'Store Locator',
              style: AppTextStyles.h2,
            ),
            SizedBox(height: AppSizes.md),
            Text(
              'Price comparison across Saudi supermarkets coming soon',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
