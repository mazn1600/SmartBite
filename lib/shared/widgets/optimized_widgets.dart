import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

/// Optimized and reusable widgets for SmartBite app
/// All widgets use const constructors and are optimized for performance

/// Optimized macro nutrient card with better performance
class OptimizedMacroNutrientCard extends StatelessWidget {
  final String name;
  final double current;
  final double target;
  final Color backgroundColor;
  final Color progressColor;
  final String unit;
  final double? width;
  final double? height;

  const OptimizedMacroNutrientCard({
    super.key,
    required this.name,
    required this.current,
    required this.target,
    required this.backgroundColor,
    required this.progressColor,
    this.unit = 'g',
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);
    final progressText = '${current.toInt()}/${target.toInt()}$unit';

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: const [AppShadows.small],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  progressText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            _ProgressBar(
              progress: progress,
              progressColor: progressColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// Optimized progress bar widget
class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color progressColor;

  const _ProgressBar({
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

/// Optimized macro nutrient grid
class OptimizedMacroNutrientGrid extends StatelessWidget {
  final double carbs;
  final double carbsTarget;
  final double protein;
  final double proteinTarget;
  final double fats;
  final double fatsTarget;
  final bool isCompact;

  const OptimizedMacroNutrientGrid({
    super.key,
    required this.carbs,
    required this.carbsTarget,
    required this.protein,
    required this.proteinTarget,
    required this.fats,
    required this.fatsTarget,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Row(
        children: [
          Expanded(
            child: OptimizedMacroNutrientCard(
              name: 'Carbs',
              current: carbs,
              target: carbsTarget,
              backgroundColor: AppColors.carbBlue,
              progressColor: AppColors.info,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: OptimizedMacroNutrientCard(
              name: 'Protein',
              current: protein,
              target: proteinTarget,
              backgroundColor: AppColors.proteinGreen,
              progressColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: OptimizedMacroNutrientCard(
              name: 'Fats',
              current: fats,
              target: fatsTarget,
              backgroundColor: AppColors.fatOrange,
              progressColor: AppColors.accent,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        OptimizedMacroNutrientCard(
          name: 'Carbs',
          current: carbs,
          target: carbsTarget,
          backgroundColor: AppColors.carbBlue,
          progressColor: AppColors.info,
        ),
        const SizedBox(height: AppSizes.sm),
        OptimizedMacroNutrientCard(
          name: 'Proteins',
          current: protein,
          target: proteinTarget,
          backgroundColor: AppColors.proteinGreen,
          progressColor: AppColors.primary,
        ),
        const SizedBox(height: AppSizes.sm),
        OptimizedMacroNutrientCard(
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

/// Optimized meal item card with better performance
class OptimizedMealItemCard extends StatelessWidget {
  final String name;
  final String calories;
  final String? imageUrl;
  final VoidCallback? onAdd;
  final VoidCallback? onCheck;
  final VoidCallback? onRemove;
  final bool isConsumed;
  final bool showActions;

  const OptimizedMealItemCard({
    super.key,
    required this.name,
    required this.calories,
    this.imageUrl,
    this.onAdd,
    this.onCheck,
    this.onRemove,
    this.isConsumed = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isConsumed
            ? AppColors.lightGreen.withOpacity(0.3)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: const [AppShadows.small],
        border:
            isConsumed ? Border.all(color: AppColors.success, width: 1) : null,
      ),
      child: Row(
        children: [
          _FoodImage(imageUrl: imageUrl),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _FoodDetails(name: name, calories: calories),
          ),
          if (showActions)
            _ActionButtons(
              onAdd: onAdd,
              onCheck: onCheck,
              onRemove: onRemove,
              isConsumed: isConsumed,
            ),
        ],
      ),
    );
  }
}

/// Optimized food image widget
class _FoodImage extends StatelessWidget {
  final String? imageUrl;

  const _FoodImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _DefaultFoodIcon(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            )
          : const _DefaultFoodIcon(),
    );
  }
}

/// Default food icon widget
class _DefaultFoodIcon extends StatelessWidget {
  const _DefaultFoodIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.fastfood,
      color: AppColors.primary,
      size: 24,
    );
  }
}

/// Food details widget
class _FoodDetails extends StatelessWidget {
  final String name;
  final String calories;

  const _FoodDetails({
    required this.name,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '$calories Cal',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Action buttons widget
class _ActionButtons extends StatelessWidget {
  final VoidCallback? onAdd;
  final VoidCallback? onCheck;
  final VoidCallback? onRemove;
  final bool isConsumed;

  const _ActionButtons({
    this.onAdd,
    this.onCheck,
    this.onRemove,
    this.isConsumed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onAdd != null)
          _ActionButton(
            onPressed: onAdd,
            icon: Icons.add_circle_outline,
            color: AppColors.primary,
          ),
        if (onCheck != null)
          _ActionButton(
            onPressed: onCheck,
            icon: isConsumed ? Icons.check_circle : Icons.check_circle_outline,
            color: isConsumed ? AppColors.success : AppColors.success,
          ),
        if (onRemove != null)
          _ActionButton(
            onPressed: onRemove,
            icon: Icons.cancel_outlined,
            color: AppColors.error,
          ),
      ],
    );
  }
}

/// Individual action button widget
class _ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;

  const _ActionButton({
    this.onPressed,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      padding: EdgeInsets.zero,
    );
  }
}

/// Optimized circular progress indicator
class OptimizedCircularProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double size;
  final bool showLabel;

  const OptimizedCircularProgressIndicator({
    super.key,
    required this.progress,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.size = 80.0,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 6.0,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: size * 0.2,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (showLabel)
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: size * 0.1,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized calorie circular progress
class OptimizedCalorieCircularProgress extends StatelessWidget {
  final double eaten;
  final double target;
  final double burned;
  final double size;
  final bool showBurned;

  const OptimizedCalorieCircularProgress({
    super.key,
    required this.eaten,
    required this.target,
    required this.burned,
    this.size = 80.0,
    this.showBurned = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (eaten / target).clamp(0.0, 1.0);
    final remaining = (target - eaten).clamp(0.0, target);

    return OptimizedCircularProgressIndicator(
      progress: progress,
      label: showBurned
          ? 'Burned: ${burned.toInt()}'
          : 'Remaining: ${remaining.toInt()}',
      value: '${eaten.toInt()}',
      icon: Icons.local_fire_department,
      color: _getProgressColor(progress),
      size: size,
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppColors.success;
    if (progress >= 0.8) return AppColors.warning;
    return AppColors.primary;
  }
}

/// Optimized loading widget
class OptimizedLoadingWidget extends StatelessWidget {
  final String message;
  final double size;
  final Color color;

  const OptimizedLoadingWidget({
    super.key,
    required this.message,
    this.size = 50.0,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 3.0,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Optimized empty state widget
class OptimizedEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const OptimizedEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              title,
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: AppSizes.lg),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
