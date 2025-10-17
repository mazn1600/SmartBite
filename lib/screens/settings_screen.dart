import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool remindersEnabled = true;
  bool wearablesEnabled = false;
  bool offlineMode = false;
  bool analyticsAllowed = true;
  bool weeklyInsights = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        children: [
          _sectionHeader('Reminders'),
          _toggleTile(
            title: 'Meal & Water Reminders',
            subtitle: 'Get reminders to log meals and drink water',
            value: remindersEnabled,
            onChanged: (v) => setState(() => remindersEnabled = v),
          ),
          const Divider(height: 1),
          _sectionHeader('Wearables'),
          _toggleTile(
            title: 'Connect Wearables',
            subtitle: 'Sync steps and heart rate to refine calorie burn',
            value: wearablesEnabled,
            onChanged: (v) => setState(() => wearablesEnabled = v),
          ),
          const Divider(height: 1),
          _sectionHeader('Offline-first'),
          _toggleTile(
            title: 'Offline Mode',
            subtitle: 'Cache logs and sync when online',
            value: offlineMode,
            onChanged: (v) => setState(() => offlineMode = v),
          ),
          const Divider(height: 1),
          _sectionHeader('Privacy & Analytics'),
          _toggleTile(
            title: 'Share Anonymous Analytics',
            subtitle: 'Help improve SmartBite without sharing personal data',
            value: analyticsAllowed,
            onChanged: (v) => setState(() => analyticsAllowed = v),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export My Data'),
            subtitle: const Text('Export logs as CSV (demo)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exported CSV (demo)')),
              );
            },
          ),
          const Divider(height: 1),
          _sectionHeader('Progress & Insights'),
          _toggleTile(
            title: 'Weekly Insights',
            subtitle: 'Show trends, streaks, and macro distribution',
            value: weeklyInsights,
            onChanged: (v) => setState(() => weeklyInsights = v),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.lg, AppSizes.lg, AppSizes.lg, AppSizes.sm),
      child: Text(
        title,
        style: AppTextStyles.h6.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _toggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
