import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();
  static const String _foodImagesFolder = 'food_images';

  /// Pick an image from gallery or camera
  Future<String?> pickFoodImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85, // Compress to 85% quality
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        // Save to local storage and return the path
        return await _saveImageToLocal(image);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Save image to local storage
  Future<String> _saveImageToLocal(XFile image) async {
    try {
      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String foodImagesPath = path.join(appDir.path, _foodImagesFolder);

      // Create the food_images directory if it doesn't exist
      final Directory foodImagesDir = Directory(foodImagesPath);
      if (!await foodImagesDir.exists()) {
        await foodImagesDir.create(recursive: true);
      }

      // Generate unique filename
      final String fileName =
          'food_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String localPath = path.join(foodImagesPath, fileName);

      // Copy the image to local storage
      final File localFile = File(localPath);
      await localFile.writeAsBytes(await image.readAsBytes());

      debugPrint('Image saved to: $localPath');
      return localPath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      throw Exception('Failed to save image: $e');
    }
  }

  /// Get image file from local path
  Future<File?> getImageFile(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        return imageFile;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting image file: $e');
      return null;
    }
  }

  /// Delete image from local storage
  Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        debugPrint('Image deleted: $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Get all food images
  Future<List<String>> getAllFoodImages() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String foodImagesPath = path.join(appDir.path, _foodImagesFolder);
      final Directory foodImagesDir = Directory(foodImagesPath);

      if (!await foodImagesDir.exists()) {
        return [];
      }

      final List<FileSystemEntity> files = await foodImagesDir.list().toList();
      return files
          .where((file) => file is File && file.path.endsWith('.jpg'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      debugPrint('Error getting food images: $e');
      return [];
    }
  }

  /// Get storage size of food images folder
  Future<int> getFoodImagesStorageSize() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String foodImagesPath = path.join(appDir.path, _foodImagesFolder);
      final Directory foodImagesDir = Directory(foodImagesPath);

      if (!await foodImagesDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final FileSystemEntity entity
          in foodImagesDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('Error getting storage size: $e');
      return 0;
    }
  }

  /// Clear all food images (useful for cleanup)
  Future<bool> clearAllFoodImages() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String foodImagesPath = path.join(appDir.path, _foodImagesFolder);
      final Directory foodImagesDir = Directory(foodImagesPath);

      if (await foodImagesDir.exists()) {
        await foodImagesDir.delete(recursive: true);
        debugPrint('All food images cleared');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error clearing food images: $e');
      return false;
    }
  }
}
