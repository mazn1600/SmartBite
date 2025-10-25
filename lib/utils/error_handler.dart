import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Centralized error handling utility for SmartBite app
class ErrorHandler {
  /// Shows a user-friendly error message
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppColors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Shows a success message
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a warning message
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Shows an info message
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Hides the loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Shows an error dialog with retry option
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? retryText,
    VoidCallback? onRetry,
    String? cancelText,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTextStyles.h5.copyWith(color: AppColors.error),
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(cancelText),
            ),
          if (retryText != null && onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(retryText),
            ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTextStyles.h5),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

/// Custom exception classes for better error handling
class SmartBiteException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const SmartBiteException(this.message, {this.code, this.details});

  @override
  String toString() => 'SmartBiteException: $message';
}

class NetworkException extends SmartBiteException {
  const NetworkException(super.message, {super.code, super.details});
}

class ValidationException extends SmartBiteException {
  const ValidationException(super.message, {super.code, super.details});
}

class AuthenticationException extends SmartBiteException {
  const AuthenticationException(super.message, {super.code, super.details});
}

class DatabaseException extends SmartBiteException {
  const DatabaseException(super.message, {super.code, super.details});
}

/// Error result wrapper for service methods
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.error(String error) =>
      Result._(error: error, isSuccess: false);

  bool get isError => !isSuccess;
}

/// Extension for handling Result objects
extension ResultExtension<T> on Result<T> {
  /// Executes a function if the result is successful
  void onSuccess(void Function(T data) callback) {
    if (isSuccess && data != null) {
      callback(data!);
    }
  }

  /// Executes a function if the result is an error
  void onError(void Function(String error) callback) {
    if (isError && error != null) {
      callback(error!);
    }
  }

  /// Returns the data or a default value
  T orElse(T defaultValue) => isSuccess && data != null ? data! : defaultValue;
}
