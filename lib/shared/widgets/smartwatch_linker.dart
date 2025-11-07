import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class SmartwatchLinker extends StatefulWidget {
  final bool isConnected;
  final String? deviceName;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  const SmartwatchLinker({
    super.key,
    this.isConnected = false,
    this.deviceName,
    this.onConnect,
    this.onDisconnect,
  });

  @override
  State<SmartwatchLinker> createState() => _SmartwatchLinkerState();
}

class _SmartwatchLinkerState extends State<SmartwatchLinker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;

  bool _isScanning = false;
  List<String> _availableDevices = [];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scanController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ));

    if (widget.isConnected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    _scanController.repeat();

    // Simulate device discovery
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isScanning = false;
        _availableDevices = [
          'Apple Watch Series 9',
          'Samsung Galaxy Watch 6',
          'Fitbit Versa 4',
          'Garmin Venu 3',
          'Xiaomi Mi Watch',
        ];
      });
      _scanController.stop();
    });
  }

  void _connectToDevice(String deviceName) {
    // Simulate connection process
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSizes.lg),
            Text('Connecting to $deviceName...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      setState(() {
        _isScanning = false;
        _availableDevices.clear();
      });

      if (widget.onConnect != null) {
        widget.onConnect!();
      }

      _pulseController.repeat(reverse: true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully connected to $deviceName!'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  void _disconnectDevice() {
    _pulseController.stop();

    if (widget.onDisconnect != null) {
      widget.onDisconnect!();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Device disconnected'),
        backgroundColor: AppColors.warning,
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
        boxShadow: const [AppShadows.medium],
        border: Border.all(
          color: widget.isConnected ? AppColors.success : AppColors.border,
          width: widget.isConnected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.watch,
                color:
                    widget.isConnected ? AppColors.success : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Smartwatch Connection',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (widget.isConnected)
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
                    'Connected',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Watch Icon with Animation
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isConnected ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isConnected
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      border: Border.all(
                        color: widget.isConnected
                            ? AppColors.success
                            : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.watch,
                      color: widget.isConnected
                          ? AppColors.success
                          : AppColors.primary,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // Device Info
          if (widget.isConnected && widget.deviceName != null) ...[
            Center(
              child: Text(
                widget.deviceName!,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Center(
              child: Text(
                'Syncing health data...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Text(
                'No device connected',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSizes.lg),

          // Action Buttons
          if (widget.isConnected) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _disconnectDevice,
                icon: const Icon(Icons.bluetooth_disabled),
                label: const Text('Disconnect'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _startScanning,
                icon: _isScanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bluetooth_searching),
                label: Text(_isScanning ? 'Scanning...' : 'Connect Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                ),
              ),
            ),
          ],

          // Available Devices List
          if (_availableDevices.isNotEmpty) ...[
            const SizedBox(height: AppSizes.lg),
            Text(
              'Available Devices:',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            ...(_availableDevices.map((device) => Container(
                  margin: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: ListTile(
                    leading: const Icon(
                      Icons.watch,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      device,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _connectToDevice(device),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: AppSizes.sm,
                        ),
                      ),
                      child: const Text('Connect'),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ))),
          ],

          // Scanning Animation
          if (_isScanning) ...[
            const SizedBox(height: AppSizes.lg),
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    Text(
                      'Scanning for devices...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    LinearProgressIndicator(
                      value: _scanAnimation.value,
                      backgroundColor: AppColors.primary.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
