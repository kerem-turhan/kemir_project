/// Image service for handling image picking and storage.
///
/// Provides image picking, persistent storage, and cleanup operations.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'database_service.dart';

/// UUID generator for unique image identifiers.
const _uuid = Uuid();

/// Service for image picking and local storage operations.
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Reference to database service for image record management.
  final DatabaseService _db = DatabaseService.instance;

  /// Picks an image from the gallery and saves it to permanent storage.
  ///
  /// Returns the local file path where the image is stored,
  /// or null if the user cancels.
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return null;
      return await _saveImageLocally(image);
    } catch (e) {
      debugPrint('Failed to pick image from gallery: $e');
      return null;
    }
  }

  /// Takes a photo using the camera and saves it to permanent storage.
  ///
  /// Returns the local file path where the image is stored,
  /// or null if the user cancels.
  Future<String?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return null;
      return await _saveImageLocally(image);
    } catch (e) {
      debugPrint('Failed to take photo: $e');
      return null;
    }
  }

  /// Gets the images directory, creating it if necessary.
  Future<Directory> getImagesDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/note_images');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  /// Saves an image to the app's permanent storage.
  Future<String> _saveImageLocally(XFile image) async {
    final imagesDir = await getImagesDirectory();

    final originalName = image.path.split('/').last;
    final extension = originalName.contains('.')
        ? '.${originalName.split('.').last}'
        : '.jpg';
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}$extension';
    final localPath = '${imagesDir.path}/$fileName';

    await image.saveTo(localPath);
    debugPrint('Saved image to: $localPath');
    return localPath;
  }

  /// Adds an image to a note and saves the record to database.
  ///
  /// Returns the image ID if successful, null otherwise.
  Future<String?> addImageToNote({
    required String noteId,
    required String filePath,
    int displayOrder = 0,
  }) async {
    try {
      final imageId = _uuid.v4();
      await _db.addImageToNote(
        imageId: imageId,
        noteId: noteId,
        filePath: filePath,
        displayOrder: displayOrder,
      );
      return imageId;
    } catch (e) {
      debugPrint('Failed to add image to note: $e');
      return null;
    }
  }

  /// Removes an image from a note and deletes the file.
  Future<bool> removeImageFromNote({
    required String imageId,
    required String filePath,
  }) async {
    try {
      // Remove from database
      await _db.removeImageFromNote(imageId);

      // Delete file
      await deleteImage(filePath);

      return true;
    } catch (e) {
      debugPrint('Failed to remove image from note: $e');
      return false;
    }
  }

  /// Deletes an image file from local storage.
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted image: $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to delete image: $e');
      return false;
    }
  }

  /// Deletes multiple image files.
  Future<int> deleteImages(List<String> imagePaths) async {
    int deleted = 0;
    for (final path in imagePaths) {
      if (await deleteImage(path)) {
        deleted++;
      }
    }
    return deleted;
  }

  /// Cleans up orphaned images (files that exist but are not in database).
  Future<int> cleanUpOrphanedImages() async {
    try {
      final imagesDir = await getImagesDirectory();

      if (!await imagesDir.exists()) return 0;

      // Get all image paths from database
      final imageRecords = await _db.getAllImageRecords();
      final dbPaths = imageRecords.map((r) => r['file_path'] as String).toSet();

      // Find and delete files not in database
      int cleaned = 0;
      await for (final entity in imagesDir.list()) {
        if (entity is File && !dbPaths.contains(entity.path)) {
          await entity.delete();
          cleaned++;
          debugPrint('Cleaned orphaned image: ${entity.path}');
        }
      }

      return cleaned;
    } catch (e) {
      debugPrint('Failed to clean up orphaned images: $e');
      return 0;
    }
  }

  /// Validates that an image file exists at the given path.
  Future<bool> validateImagePath(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Gets the file size of an image in bytes.
  Future<int> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Checks if an image file exists.
  Future<bool> imageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Gets the total size of all images in bytes.
  Future<int> getTotalImageSize() async {
    try {
      final imagesDir = await getImagesDirectory();
      if (!await imagesDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in imagesDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}
