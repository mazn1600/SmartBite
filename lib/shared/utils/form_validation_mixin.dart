import 'package:flutter/material.dart';
import 'validators.dart';

/// Mixin for form validation in SmartBite app
/// Provides easy-to-use validation methods for common form fields
mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  final Map<String, String?> _fieldErrors = {};
  final Map<String, TextEditingController> _controllers = {};

  /// Gets error message for a field
  String? getFieldError(String fieldName) => _fieldErrors[fieldName];

  /// Sets error message for a field
  void setFieldError(String fieldName, String? error) {
    setState(() {
      _fieldErrors[fieldName] = error;
    });
  }

  /// Clears error message for a field
  void clearFieldError(String fieldName) {
    setState(() {
      _fieldErrors.remove(fieldName);
    });
  }

  /// Clears all field errors
  void clearAllErrors() {
    setState(() {
      _fieldErrors.clear();
    });
  }

  /// Validates a single field
  bool validateField(
      String fieldName, String? value, String? Function(String?) validator) {
    final error = validator(value);
    setFieldError(fieldName, error);
    return error == null;
  }

  /// Validates email field
  bool validateEmail(String fieldName, String? value) {
    return validateField(fieldName, value, Validators.email);
  }

  /// Validates password field
  bool validatePassword(String fieldName, String? value) {
    return validateField(fieldName, value, Validators.password);
  }

  /// Validates password confirmation field
  bool validatePasswordConfirmation(
      String fieldName, String? value, String? password) {
    return validateField(
        fieldName, value, (v) => Validators.confirmPassword(v, password));
  }

  /// Validates name field
  bool validateName(String fieldName, String? value) {
    return validateField(fieldName, value, Validators.name);
  }

  /// Validates age field
  bool validateAge(String fieldName, String? value) {
    return validateField(fieldName, value, Validators.age);
  }

  /// Validates height field
  bool validateHeight(String fieldName, String? value) {
    return validateField(fieldName, value, Validators.height);
  }

  /// Validates weight field
  bool validateWeight(String fieldName, String? value) {
    return validateField(fieldName, value, Validators.weight);
  }

  /// Validates target weight field
  bool validateTargetWeight(
      String fieldName, String? value, double currentWeight) {
    return validateField(
        fieldName, value, (v) => Validators.targetWeight(v, currentWeight));
  }

  /// Validates gender field
  bool validateGender(String fieldName, String? value) {
    return validateField(fieldName, value, Validators.gender);
  }

  /// Validates activity level field
  bool validateActivityLevel(String fieldName, String? value) {
    return validateField(fieldName, value, Validators.activityLevel);
  }

  /// Validates goal field
  bool validateGoal(String fieldName, String? value) {
    return validateField(fieldName, value, Validators.goal);
  }

  /// Validates required field
  bool validateRequired(
      String fieldName, String? value, String fieldDisplayName) {
    return validateField(
        fieldName, value, (v) => Validators.required(v, fieldDisplayName));
  }

  /// Validates positive number field
  bool validatePositiveNumber(
      String fieldName, String? value, String fieldDisplayName) {
    return validateField(fieldName, value,
        (v) => Validators.positiveNumber(v, fieldDisplayName));
  }

  /// Validates integer field
  bool validateInteger(
      String fieldName, String? value, String fieldDisplayName) {
    return validateField(
        fieldName, value, (v) => Validators.integerValue(v, fieldDisplayName));
  }

  /// Validates double field
  bool validateDouble(
      String fieldName, String? value, String fieldDisplayName) {
    return validateField(
        fieldName, value, (v) => Validators.doubleValue(v, fieldDisplayName));
  }

  /// Validates all fields in a form
  bool validateForm(Map<String, String> fieldValues,
      Map<String, String? Function(String?)> validators) {
    bool isValid = true;
    clearAllErrors();

    for (final entry in fieldValues.entries) {
      final fieldName = entry.key;
      final value = entry.value;
      final validator = validators[fieldName];

      if (validator != null) {
        final fieldValid = validateField(fieldName, value, validator);
        if (!fieldValid) {
          isValid = false;
        }
      }
    }

    return isValid;
  }

  /// Gets a text controller for a field
  TextEditingController getController(String fieldName) {
    if (!_controllers.containsKey(fieldName)) {
      _controllers[fieldName] = TextEditingController();
    }
    return _controllers[fieldName]!;
  }

  /// Disposes all controllers
  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Creates a text form field with validation
  Widget buildTextFormField({
    required String fieldName,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int? maxLines,
    int? maxLength,
    TextInputAction? textInputAction,
    void Function(String)? onChanged,
    void Function()? onTap,
    bool readOnly = false,
    String? initialValue,
  }) {
    return TextFormField(
      controller: getController(fieldName),
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onChanged: (value) {
        clearFieldError(fieldName);
        onChanged?.call(value);
      },
      onTap: onTap,
      validator: (value) {
        final error = validator(value);
        setFieldError(fieldName, error);
        return error;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: getFieldError(fieldName),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  /// Creates a dropdown form field with validation
  Widget buildDropdownFormField<T>({
    required String fieldName,
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required String? Function(T?) validator,
    void Function(T?)? onChanged,
    String? hintText,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: (newValue) {
        clearFieldError(fieldName);
        onChanged?.call(newValue);
      },
      validator: (value) {
        final error = validator(value);
        setFieldError(fieldName, error);
        return error;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: getFieldError(fieldName),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  /// Creates a checkbox list tile with validation
  Widget buildCheckboxListTile({
    required String fieldName,
    required String title,
    required bool value,
    required void Function(bool?) onChanged,
    String? subtitle,
  }) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: (newValue) {
        clearFieldError(fieldName);
        onChanged(newValue);
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  /// Creates a radio list tile with validation
  Widget buildRadioListTile<T>({
    required String fieldName,
    required String title,
    required T value,
    required T groupValue,
    required void Function(T?) onChanged,
    String? subtitle,
  }) {
    return RadioListTile<T>(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        clearFieldError(fieldName);
        onChanged(newValue);
      },
    );
  }
}
