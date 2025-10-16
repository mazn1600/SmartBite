import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_theme.dart';

class BMIDragDrop extends StatefulWidget {
  final double? initialBMI;
  final ValueChanged<double> onBMIChanged;
  final String? inBodyData;

  const BMIDragDrop({
    super.key,
    this.initialBMI,
    required this.onBMIChanged,
    this.inBodyData,
  });

  @override
  State<BMIDragDrop> createState() => _BMIDragDropState();
}

class _BMIDragDropState extends State<BMIDragDrop>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  double _currentBMI = 22.0;
  bool _isDragging = false;
  bool _hasInBodyData = false;
  String _bmiCategory = 'Normal';
  Color _bmiColor = AppColors.success;

  @override
  void initState() {
    super.initState();
    _currentBMI = widget.initialBMI ?? 22.0;
    _hasInBodyData = widget.inBodyData != null;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _updateBMICategory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateBMICategory() {
    if (_currentBMI < 18.5) {
      _bmiCategory = 'Underweight';
      _bmiColor = AppColors.info;
    } else if (_currentBMI < 25) {
      _bmiCategory = 'Normal';
      _bmiColor = AppColors.success;
    } else if (_currentBMI < 30) {
      _bmiCategory = 'Overweight';
      _bmiColor = AppColors.warning;
    } else {
      _bmiCategory = 'Obese';
      _bmiColor = AppColors.error;
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      // Convert drag delta to BMI change (sensitivity adjustment)
      final delta =
          details.delta.dy * -0.1; // Negative for upward drag = higher BMI
      _currentBMI = math.max(10.0, math.min(50.0, _currentBMI + delta));
      _updateBMICategory();
    });

    if (!_animationController.isAnimating) {
      _animationController.forward();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    _animationController.reverse();
    widget.onBMIChanged(_currentBMI);
  }

  void _onInBodyDataDropped(String data) {
    setState(() {
      _hasInBodyData = true;
      // Parse InBody data (this would be more complex in real implementation)
      // For demo, we'll extract BMI from the data
      final bmiMatch = RegExp(r'BMI[:\s]*(\d+\.?\d*)').firstMatch(data);
      if (bmiMatch != null) {
        _currentBMI = double.parse(bmiMatch.group(1)!);
        _updateBMICategory();
        widget.onBMIChanged(_currentBMI);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('InBody data imported successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [AppShadows.medium],
        border: Border.all(
          color: _isDragging ? AppColors.primary : AppColors.border,
          width: _isDragging ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_weight,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'BMI Calculator',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_hasInBodyData)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    'InBody Connected',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // BMI Display Circle
          GestureDetector(
            onPanUpdate: _onDragUpdate,
            onPanEnd: _onDragEnd,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _bmiColor.withOpacity(0.1),
                        border: Border.all(
                          color: _bmiColor,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentBMI.toStringAsFixed(1),
                            style: AppTextStyles.h3.copyWith(
                              color: _bmiColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'BMI',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _bmiColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // BMI Category
          Text(
            _bmiCategory,
            style: AppTextStyles.labelLarge.copyWith(
              color: _bmiColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          // Instructions
          Text(
            'Drag up/down to adjust BMI',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // InBody Data Drop Zone
          DragTarget<String>(
            onWillAcceptWithDetails: (details) => true,
            onAcceptWithDetails: (details) {
              _onInBodyDataDropped(details.data);
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? AppColors.primary
                        : AppColors.border,
                    style: candidateData.isNotEmpty
                        ? BorderStyle.solid
                        : BorderStyle.solid,
                    width: candidateData.isNotEmpty ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      color: candidateData.isNotEmpty
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 32,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      candidateData.isNotEmpty
                          ? 'Drop InBody data here'
                          : 'Drop InBody data here',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: candidateData.isNotEmpty
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: candidateData.isNotEmpty
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'or drag from InBody app',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// InBody Data Source Widget (for demonstration)
class InBodyDataSource extends StatelessWidget {
  final String data;

  const InBodyDataSource({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: data,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center,
                color: AppColors.white,
                size: 20,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'InBody Data',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              color: AppColors.grey,
              size: 20,
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              'InBody Data',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.lightGreen,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              'InBody Data',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
