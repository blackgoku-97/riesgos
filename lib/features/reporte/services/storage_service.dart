import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  /// Sube un archivo a Firebase Storage y devuelve la URL pública
  static Future<String?> uploadFile({
    required File file,
    required String path,
  }) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await ref.putFile(file);

      if (uploadTask.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        throw Exception("Error al subir archivo");
      }
    } catch (e) {
      throw Exception("Error en StorageService: $e");
    }
  }

  /// Elimina un archivo de Firebase Storage
  static Future<void> deleteFile(String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.delete();
    } catch (e) {
      throw Exception("Error al eliminar archivo: $e");
    }
  }
}