import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

/// Progress card widget showing today's progress
class ProgressCard extends StatelessWidget {
  final double caloriesConsumed;
  final double caloriesTarget;
  final double caloriesBurned;
  final double progressPercentage;

  const ProgressCard({
    super.key,
    required this.caloriesConsumed,
    required this.caloriesTarget,
    required this.caloriesBurned,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: const [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Progress",
            style: AppTextStyles.h5.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Eaten',
                caloriesConsumed.toInt().toString(),
                AppColors.white,
                Icons.restaurant,
              ),
              _buildCircularProgress(),
              _buildStatItem(
                'Burned',
                caloriesBurned.toInt().toString(),
                AppColors.white,
                Icons.local_fire_department,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Target: ${caloriesTarget.toInt()} kcal',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSizes.xs),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progressPercentage.clamp(0.0, 1.0),
            strokeWidth: 8,
            backgroundColor: AppColors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
          Text(
            '${(progressPercentage * 100).toInt()}%',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
