import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/open_food_facts_service.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  bool _isProcessing = false;
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE
    ],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) async {
                if (_isProcessing) return;
                final barcodes = capture.barcodes;
                if (barcodes.isEmpty) return;
                final raw = barcodes.first.rawValue;
                if (raw == null) return;

                setState(() => _isProcessing = true);
                final product =
                    await OpenFoodFactsService.fetchProductByBarcode(raw);
                setState(() => _isProcessing = false);

                if (!mounted) return;
                if (product == null) {
                  ScaffoldMessenger.of(BuildContext as BuildContext)
                      .showSnackBar(
                    SnackBar(content: Text('No info found for barcode $raw')),
                  );
                  return;
                }

                final nutrition = OpenFoodFactsService.parseNutrition(product);
                showModalBottomSheet(
                  context: BuildContext as BuildContext,
                  builder: (_) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nutrition['name'] ?? 'Unknown',
                            style: AppTextStyles.h5
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                              'Per 100g: ${nutrition['caloriesPer100g'].toStringAsFixed(0)} kcal, P ${nutrition['proteinPer100g']}g, C ${nutrition['carbsPer100g']}g, F ${nutrition['fatPer100g']}g'),
                          const SizedBox(height: AppSizes.md),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Logged (demo)')),
                                );
                              },
                              child: const Text('Log this food'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isProcessing) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'Point the camera at a barcode',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
