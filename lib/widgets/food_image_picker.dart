import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/image_service.dart';

class FoodImagePicker extends StatefulWidget {
  final String? initialImagePath;
  final Function(String?) onImageSelected;
  final String? label;
  final bool isRequired;

  const FoodImagePicker({
    super.key,
    this.initialImagePath,
    required this.onImageSelected,
    this.label,
    this.isRequired = false,
  });

  @override
  State<FoodImagePicker> createState() => _FoodImagePickerState();
}

class _FoodImagePickerState extends State<FoodImagePicker> {
  String? _selectedImagePath;
  final ImageService _imageService = ImageService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.initialImagePath;
  }

  Future<void> _pickImage({bool fromCamera = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? imagePath =
          await _imageService.pickFoodImage(fromCamera: fromCamera);

      if (imagePath != null) {
        setState(() {
          _selectedImagePath = imagePath;
        });
        widget.onImageSelected(imagePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeImage() async {
    if (_selectedImagePath != null) {
      await _imageService.deleteImage(_selectedImagePath!);
      setState(() {
        _selectedImagePath = null;
      });
      widget.onImageSelected(null);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(fromCamera: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(fromCamera: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
        ],
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedImagePath != null
                  ? AppColors.primary
                  : AppColors.border,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            color: AppColors.surface,
          ),
          child: _selectedImagePath != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      child: Image.file(
                        File(_selectedImagePath!),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.white,
                            size: 20,
                          ),
                          onPressed: _removeImage,
                        ),
                      ),
                    ),
                  ],
                )
              : _buildPlaceholder(),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: AppSizes.sm),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return InkWell(
      onTap: _isLoading ? null : _showImageSourceDialog,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          color: AppColors.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Add Food Photo',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Tap to select from gallery or camera',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
