import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class VoiceLogScreen extends StatefulWidget {
  const VoiceLogScreen({super.key});

  @override
  State<VoiceLogScreen> createState() => _VoiceLogScreenState();
}

class _VoiceLogScreenState extends State<VoiceLogScreen> {
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Log'),
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRecording ? Icons.mic : Icons.mic_none,
              size: 80,
              color: isRecording ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              isRecording ? 'Listening...' : 'Tap to start speaking',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => isRecording = !isRecording);
                if (isRecording) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recording started (demo)')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recording stopped (demo)')),
                  );
                }
              },
              icon: Icon(isRecording ? Icons.stop : Icons.mic),
              label: Text(isRecording ? 'Stop' : 'Record'),
            ),
          ],
        ),
      ),
    );
  }
}
