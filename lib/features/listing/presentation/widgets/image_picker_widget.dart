import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/image_upload_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(List<String>)? onImagesSelected;
  final int maxImages;

  const ImagePickerWidget({
    super.key,
    this.onImagesSelected,
    this.maxImages = 10,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final List<String> _imageUrls = [];
  bool _isUploading = false;

  Future<void> _pickImages() async {
    try {
      final images = await ImageUploadService.pickMultipleImages(
        maxImages: widget.maxImages,
      );

      if (images.isEmpty) return;

      setState(() => _isUploading = true);

      final urls = await ImageUploadService.uploadMultipleImages(
        imageFiles: images,
        bucket: 'listing-images',
        folder: 'listings',
      );

      setState(() {
        _imageUrls.addAll(urls);
        _isUploading = false;
      });

      widget.onImagesSelected?.call(_imageUrls);
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
    widget.onImagesSelected?.call(_imageUrls);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imageUrls.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imageUrls[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickImages,
          icon: _isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_photo_alternate),
          label: Text(
            _isUploading ? 'Upload en cours...' : 'Ajouter des photos',
          ),
        ),
      ],
    );
  }
}
