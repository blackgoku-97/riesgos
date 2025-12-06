import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagenService {
  static Future<File?> tomarFoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (picked != null) {
        return File(picked.path);
      }
    } catch (_) {}
    return null;
  }
}