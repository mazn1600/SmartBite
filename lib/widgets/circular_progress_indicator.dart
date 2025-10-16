import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double size;

  const CustomCircularProgressIndicator({
    super.key,
    required this.progress,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              value: progress,
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
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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

class CalorieCircularProgress extends StatelessWidget {
  final double eaten;
  final double target;
  final double burned;
  final double size;

  const CalorieCircularProgress({
    super.key,
    required this.eaten,
    required this.target,
    required this.burned,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    final progress = eaten / target;

    return Container(
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
              color: AppColors.primary.withOpacity(0.1),
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppColors.primary,
                  size: size * 0.2,
                ),
                SizedBox(height: 2),
                Text(
                  '${target.toInt()}',
                  style: TextStyle(
                    fontSize: size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Cals',
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
