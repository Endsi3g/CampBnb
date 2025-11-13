import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';

class ImageUploadService {
  ImageUploadService._();

  static final ImagePicker _picker = ImagePicker();

  /// Sélectionner une image depuis la galerie
  static Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }

  /// Prendre une photo avec la caméra
  static Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }

  /// Sélectionner plusieurs images
  static Future<List<File>> pickMultipleImages({int maxImages = 10}) async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    return images.map((xFile) => File(xFile.path)).toList();
  }

  /// Uploader une image vers Supabase Storage
  static Future<String> uploadImage({
    required File imageFile,
    required String bucket,
    String? folder,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final filePath = folder != null ? '$folder/$fileName' : fileName;

      // Lire le fichier
      final bytes = await imageFile.readAsBytes();

      // Upload vers Supabase Storage
      final supabase = Supabase.instance.client;
      await supabase.storage
          .from(bucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Obtenir l'URL publique
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Uploader plusieurs images
  static Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    required String bucket,
    String? folder,
  }) async {
    final List<String> urls = [];

    for (final imageFile in imageFiles) {
      try {
        final url = await uploadImage(
          imageFile: imageFile,
          bucket: bucket,
          folder: folder,
        );
        urls.add(url);
      } catch (e) {
        // Continuer avec les autres images même si une échoue
        continue;
      }
    }

    return urls;
  }

  /// Supprimer une image de Supabase Storage
  static Future<void> deleteImage({
    required String bucket,
    required String filePath,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.storage.from(bucket).remove([filePath]);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image: $e');
    }
  }

  /// Compresser une image avant l'upload
  static Future<File?> compressImage(File imageFile) async {
    // TODO: Implémenter la compression avec flutter_image_compress si nécessaire
    // Pour l'instant, on retourne le fichier tel quel
    return imageFile;
  }
}
