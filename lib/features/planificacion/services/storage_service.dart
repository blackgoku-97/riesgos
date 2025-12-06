import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static Future<String> uploadFile({
    required File file,
    required String path,
    Map<String, String>? metadata,
    void Function(double progress)? onProgress,
  }) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(customMetadata: metadata ?? {}),
    );
    uploadTask.snapshotEvents.listen((s) {
      final total = s.totalBytes;
      final transferred = s.bytesTransferred;
      if (total > 0 && onProgress != null) {
        onProgress(transferred / total);
      }
    });
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  static Future<void> deleteFile(String path) async {
    await FirebaseStorage.instance.ref().child(path).delete();
  }
}