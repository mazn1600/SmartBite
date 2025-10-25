import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';
import '../utils/validators.dart';

/// Comprehensive form widgets for SmartBite app
/// All widgets are optimized for performance and reusability

/// Optimized text form field with built-in validation
class SmartBiteTextFormField extends StatelessWidget {
  final String fieldName;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final String? initialValue;
  final bool enabled;
  final FocusNode? focusNode;

  const SmartBiteTextFormField({
    super.key,
    required this.fieldName,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.maxLength,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.initialValue,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      textInputAction: textInputAction,
      readOnly: readOnly,
      enabled: enabled,
      focusNode: focusNode,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
    );
  }
}

/// Email form field with built-in validation
class EmailFormField extends StatelessWidget {
  final String fieldName;
  final String? initialValue;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const EmailFormField({
    super.key,
    required this.fieldName,
    this.initialValue,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SmartBiteTextFormField(
      fieldName: fieldName,
      label: 'Email',
      hintText: 'Enter your email address',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: Validators.email,
      onChanged: onChanged,
      initialValue: initialValue,
      focusNode: focusNode,
      prefixIcon: const Icon(Icons.email_outlined),
    );
  }
}

/// Password form field with built-in validation
class PasswordFormField extends StatefulWidget {
  final String fieldName;
  final String? initialValue;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool showStrengthIndicator;

  const PasswordFormField({
    super.key,
    required this.fieldName,
    this.initialValue,
    this.onChanged,
    this.focusNode,
    this.showStrengthIndicator = false,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SmartBiteTextFormField(
          fieldName: widget.fieldName,
          label: 'Password',
          hintText: 'Enter your password',
          obscureText: _obscureText,
          textInputAction: TextInputAction.done,
          validator: Validators.password,
          onChanged: widget.onChanged,
          initialValue: widget.initialValue,
          focusNode: widget.focusNode,
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
        if (widget.showStrengthIndicator) ...[
          const SizedBox(height: AppSizes.sm),
          const _PasswordStrengthIndicator(),
        ],
      ],
    );
  }
}

/// Password strength indicator
class _PasswordStrengthIndicator extends StatelessWidget {
  const _PasswordStrengthIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Name form field with built-in validation
class NameFormField extends StatelessWidget {
  final String fieldName;
  final String? initialValue;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const NameFormField({
    super.key,
    required this.fieldName,
    this.initialValue,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SmartBiteTextFormField(
      fieldName: fieldName,
      label: 'Full Name',
      hintText: 'Enter your full name',
      textInputAction: TextInputAction.next,
      validator: Validators.name,
      onChanged: onChanged,
      initialValue: initialValue,
      focusNode: focusNode,
      prefixIcon: const Icon(Icons.person_outlined),
    );
  }
}

/// Age form field with built-in validation
class AgeFormField extends StatelessWidget {
  final String fieldName;
  final String? initialValue;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const AgeFormField({
    super.key,
    required this.fieldName,
    this.initialValue,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SmartBiteTextFormField(
      fieldName: fieldName,
      label: 'Age',
      hintText: 'Enter your age',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: Validators.age,
      onChanged: onChanged,
      initialValue: initialValue,
      focusNode: focusNode,
      prefixIcon: const Icon(Icons.cake_outlined),
    );
  }
}

/// Height form field with built-in validation
class HeightFormField extends StatelessWidget {
  final String fieldName;
  final String? initialValue;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const HeightFormField({
    super.key,
    required this.fieldName,
    this.initialValue,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SmartBiteTextFormField(
      fieldName: fieldName,
      label: 'Height (cm)',
      hintText: 'Enter your height in cm',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: Validators.height,
      onChanged: onChanged,
      initialValue: initialValue,
      focusNode: focusNode,
      prefixIcon: const Icon(Icons.height),
    );
  }
}

/// Weight form field with built-in validation
class WeightFormField extends StatelessWidget {
  final String fieldName;
  final String? initialValue;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const WeightFormField({
    super.key,
    required this.fieldName,
    this.initialValue,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SmartBiteTextFormField(
      fieldName: fieldName,
      label: 'Weight (kg)',
      hintText: 'Enter your weight in kg',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: Validators.weight,
      onChanged: onChanged,
      initialValue: initialValue,
      focusNode: focusNode,
      prefixIcon: const Icon(Icons.monitor_weight_outlined),
    );
  }
}

/// Dropdown form field with built-in validation
class SmartBiteDropdownFormField<T> extends StatelessWidget {
  final String fieldName;
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final String? hintText;
  final Widget? prefixIcon;

  const SmartBiteDropdownFormField({
    super.key,
    required this.fieldName,
    required this.label,
    required this.value,
    required this.items,
    this.validator,
    this.onChanged,
    this.hintText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }
}

/// Gender dropdown form field
class GenderFormField extends StatelessWidget {
  final String fieldName;
  final String? value;
  final void Function(String?)? onChanged;

  const GenderFormField({
    super.key,
    required this.fieldName,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SmartBiteDropdownFormField<String>(
      fieldName: fieldName,
      label: 'Gender',
      value: value,
      onChanged: onChanged,
      validator: Validators.gender,
      hintText: 'Select your gender',
      prefixIcon: const Icon(Icons.person_outline),
      items: AppConstants.genders.map((gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender.capitalize()),
        );
      }).toList(),
    );
  }
}

/// Activity level dropdown form field
class ActivityLevelFormField extends StatelessWidget {
  final String fieldName;
  final String? value;
  final void Function(String?)? onChanged;

  const ActivityLevelFormField({
    super.key,
    required this.fieldName,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SmartBiteDropdownFormField<String>(
      fieldName: fieldName,
      label: 'Activity Level',
      value: value,
      onChanged: onChanged,
      validator: Validators.activityLevel,
      hintText: 'Select your activity level',
      prefixIcon: const Icon(Icons.fitness_center_outlined),
      items: AppConstants.activityLevels.map((level) {
        return DropdownMenuItem<String>(
          value: level,
          child: Text(_formatActivityLevel(level)),
        );
      }).toList(),
    );
  }
}

/// Goal dropdown form field
class GoalFormField extends StatelessWidget {
  final String fieldName;
  final String? value;
  final void Function(String?)? onChanged;

  const GoalFormField({
    super.key,
    required this.fieldName,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SmartBiteDropdownFormField<String>(
      fieldName: fieldName,
      label: 'Goal',
      value: value,
      onChanged: onChanged,
      validator: Validators.goal,
      hintText: 'Select your goal',
      prefixIcon: const Icon(Icons.flag_outlined),
      items: AppConstants.goals.map((goal) {
        return DropdownMenuItem<String>(
          value: goal,
          child: Text(_formatGoal(goal)),
        );
      }).toList(),
    );
  }
}

/// Multi-select chip form field
class MultiSelectChipFormField extends StatelessWidget {
  final String fieldName;
  final String label;
  final List<String> selectedValues;
  final List<String> options;
  final void Function(List<String>)? onChanged;
  final String? Function(List<String>)? validator;

  const MultiSelectChipFormField({
    super.key,
    required this.fieldName,
    required this.label,
    required this.selectedValues,
    required this.options,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option.capitalize()),
              selected: isSelected,
              onSelected: (selected) {
                final newValues = List<String>.from(selectedValues);
                if (selected) {
                  newValues.add(option);
                } else {
                  newValues.remove(option);
                }
                onChanged?.call(newValues);
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Dietary preferences multi-select form field
class DietaryPreferencesFormField extends StatelessWidget {
  final String fieldName;
  final List<String> selectedValues;
  final void Function(List<String>)? onChanged;

  const DietaryPreferencesFormField({
    super.key,
    required this.fieldName,
    required this.selectedValues,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSelectChipFormField(
      fieldName: fieldName,
      label: 'Dietary Preferences',
      selectedValues: selectedValues,
      options: AppConstants.dietaryPreferences,
      onChanged: onChanged,
    );
  }
}

/// Allergies multi-select form field
class AllergiesFormField extends StatelessWidget {
  final String fieldName;
  final List<String> selectedValues;
  final void Function(List<String>)? onChanged;

  const AllergiesFormField({
    super.key,
    required this.fieldName,
    required this.selectedValues,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSelectChipFormField(
      fieldName: fieldName,
      label: 'Allergies',
      selectedValues: selectedValues,
      options: AppConstants.commonAllergens,
      onChanged: onChanged,
    );
  }
}

/// Health conditions multi-select form field
class HealthConditionsFormField extends StatelessWidget {
  final String fieldName;
  final List<String> selectedValues;
  final void Function(List<String>)? onChanged;

  const HealthConditionsFormField({
    super.key,
    required this.fieldName,
    required this.selectedValues,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSelectChipFormField(
      fieldName: fieldName,
      label: 'Health Conditions',
      selectedValues: selectedValues,
      options: AppConstants.healthConditions,
      onChanged: onChanged,
    );
  }
}

/// Helper functions
String _formatActivityLevel(String level) {
  switch (level) {
    case 'sedentary':
      return 'Sedentary (Little to no exercise)';
    case 'lightly_active':
      return 'Lightly Active (Light exercise 1-3 days/week)';
    case 'moderately_active':
      return 'Moderately Active (Moderate exercise 3-5 days/week)';
    case 'very_active':
      return 'Very Active (Hard exercise 6-7 days/week)';
    case 'extremely_active':
      return 'Extremely Active (Very hard exercise, physical job)';
    default:
      return level.capitalize();
  }
}

String _formatGoal(String goal) {
  switch (goal) {
    case 'weight_loss':
      return 'Weight Loss';
    case 'weight_gain':
      return 'Weight Gain';
    case 'maintenance':
      return 'Weight Maintenance';
    default:
      return goal.capitalize();
  }
}

/// Extension for string capitalization
extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
