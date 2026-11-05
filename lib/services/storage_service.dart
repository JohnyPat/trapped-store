import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageServiceException implements Exception {
  const StorageServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

class StorageService {
  StorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadProfileImage({
    required String uid,
    required XFile file,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const StorageServiceException('The selected image is empty.');
      }
      if (bytes.length > 5 * 1024 * 1024) {
        throw const StorageServiceException(
          'Please choose an image smaller than 5 MB.',
        );
      }
      final extension = _extension(file.name);
      final path =
          'users/$uid/profile_${DateTime.now().millisecondsSinceEpoch}$extension';
      final ref = _storage.ref(path);
      final task = await ref.putData(
        bytes,
        SettableMetadata(
          contentType: _contentType(extension),
          cacheControl: 'public, max-age=31536000',
        ),
      );
      return await task.ref.getDownloadURL();
    } on StorageServiceException {
      rethrow;
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found' ||
          error.code == 'bucket-not-found' ||
          error.message?.toLowerCase().contains('bucket') == true) {
        throw const StorageServiceException(
          'Firebase Storage is not enabled for this project yet. '
          'Open Firebase Console → Storage → Get started, then try again.',
        );
      }
      throw StorageServiceException(
        error.message ?? 'The profile picture could not be uploaded.',
      );
    } catch (error) {
      throw StorageServiceException(
        'The profile picture could not be uploaded. $error',
      );
    }
  }

  String _extension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1) return '.jpg';
    return name.substring(dot).toLowerCase();
  }

  String _contentType(String extension) {
    switch (extension) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
