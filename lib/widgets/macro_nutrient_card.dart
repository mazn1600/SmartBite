import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class MacroNutrientCard extends StatelessWidget {
  final String name;
  final double current;
  final double target;
  final Color backgroundColor;
  final Color progressColor;
  final String unit;

  const MacroNutrientCard({
    super.key,
    required this.name,
    required this.current,
    required this.target,
    required this.backgroundColor,
    required this.progressColor,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: const [AppShadows.small],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${current.toInt()}/${target.toInt()}$unit',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MacroNutrientGrid extends StatelessWidget {
  final double carbs;
  final double carbsTarget;
  final double protein;
  final double proteinTarget;
  final double fats;
  final double fatsTarget;

  const MacroNutrientGrid({
    super.key,
    required this.carbs,
    required this.carbsTarget,
    required this.protein,
    required this.proteinTarget,
    required this.fats,
    required this.fatsTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MacroNutrientCard(
          name: 'Carbs',
          current: carbs,
          target: carbsTarget,
          backgroundColor: AppColors.carbBlue,
          progressColor: AppColors.info,
        ),
        const SizedBox(height: AppSizes.sm),
        MacroNutrientCard(
          name: 'Proteins',
          current: protein,
          target: proteinTarget,
          backgroundColor: AppColors.proteinGreen,
          progressColor: AppColors.primary,
        ),
        const SizedBox(height: AppSizes.sm),
        MacroNutrientCard(
          name: 'Fats',
          current: fats,
          target: fatsTarget,
          backgroundColor: AppColors.fatOrange,
          progressColor: AppColors.accent,
        ),
      ],
    );
  }
}
