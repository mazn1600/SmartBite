import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

/// Water intake tracker widget
class WaterIntakeWidget extends StatefulWidget {
  final int currentGlasses;
  final int targetGlasses;
  final VoidCallback? onAddGlass;

  const WaterIntakeWidget({
    super.key,
    this.currentGlasses = 0,
    this.targetGlasses = 8,
    this.onAddGlass,
  });

  @override
  State<WaterIntakeWidget> createState() => _WaterIntakeWidgetState();
}

class _WaterIntakeWidgetState extends State<WaterIntakeWidget> {
  @override
  Widget build(BuildContext context) {
    final progress =
        (widget.currentGlasses / widget.targetGlasses).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Water Intake',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.currentGlasses}/${widget.targetGlasses}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.lightGreen,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: List.generate(
              widget.targetGlasses,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: widget.onAddGlass,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: index < widget.currentGlasses
                            ? AppColors.primary
                            : AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(
                          color: index < widget.currentGlasses
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        Icons.water_drop,
                        color: index < widget.currentGlasses
                            ? AppColors.white
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
