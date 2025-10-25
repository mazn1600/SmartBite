import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class FoodImageWidget extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const FoodImageWidget({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder();
    }

    // Check if it's a local file path or URL
    if (imagePath!.startsWith('/') || imagePath!.startsWith('file://')) {
      // Local file
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusMd),
        child: Image.file(
          File(imagePath!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _buildErrorWidget();
          },
        ),
      );
    } else if (imagePath!.startsWith('http')) {
      // Network URL
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusMd),
        child: Image.network(
          imagePath!,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ?? _buildPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _buildErrorWidget();
          },
        ),
      );
    } else {
      // Assume it's a local file path
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusMd),
        child: Image.file(
          File(imagePath!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _buildErrorWidget();
          },
        ),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusMd),
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(
        Icons.restaurant,
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.4 : height! * 0.4)
            : 40,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusMd),
        color: AppColors.error.withOpacity(0.1),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: (width != null && height != null)
                ? (width! < height! ? width! * 0.3 : height! * 0.3)
                : 30,
            color: AppColors.error,
          ),
          const SizedBox(height: 4),
          Text(
            'Image Error',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
