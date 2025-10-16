import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class MealItemCard extends StatelessWidget {
  final String name;
  final String calories;
  final String? imageUrl;
  final VoidCallback? onAdd;
  final VoidCallback? onCheck;
  final VoidCallback? onRemove;

  const MealItemCard({
    super.key,
    required this.name,
    required this.calories,
    this.imageUrl,
    this.onAdd,
    this.onCheck,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [AppShadows.small],
      ),
      child: Row(
        children: [
          // Food image placeholder
          Container(
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
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.fastfood,
                          color: AppColors.primary,
                          size: 24,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.fastfood,
                    color: AppColors.primary,
                    size: 24,
                  ),
          ),
          const SizedBox(width: AppSizes.md),
          // Food details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$calories Cal',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            children: [
              if (onAdd != null)
                IconButton(
                  onPressed: onAdd,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                  ),
                ),
              if (onCheck != null)
                IconButton(
                  onPressed: onCheck,
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class MealSection extends StatelessWidget {
  final String mealName;
  final String calories;
  final List<MealItem> items;
  final VoidCallback? onAddItem;

  const MealSection({
    super.key,
    required this.mealName,
    required this.calories,
    required this.items,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mealName,
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Text(
                  '$calories cal',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (onAddItem != null) ...[
                  const SizedBox(width: AppSizes.sm),
                  IconButton(
                    onPressed: onAddItem,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        ...items.map((item) => MealItemCard(
              name: item.name,
              calories: item.calories,
              imageUrl: item.imageUrl,
              onAdd: item.onAdd,
              onCheck: item.onCheck,
              onRemove: item.onRemove,
            )),
      ],
    );
  }
}

class MealItem {
  final String name;
  final String calories;
  final String? imageUrl;
  final VoidCallback? onAdd;
  final VoidCallback? onCheck;
  final VoidCallback? onRemove;

  MealItem({
    required this.name,
    required this.calories,
    this.imageUrl,
    this.onAdd,
    this.onCheck,
    this.onRemove,
  });
}
