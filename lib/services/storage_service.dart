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
    return _uploadImage(
      file: file,
      path:
          'users/$uid/profile_${DateTime.now().millisecondsSinceEpoch}${_extension(file.name)}',
      notEnabledMessage:
          'Firebase Storage is not enabled for this project yet. '
          'Open Firebase Console → Storage → Get started, then try again.',
      failureMessage: 'The profile picture could not be uploaded.',
    );
  }

  /// Upload an admin product photo at `products/{productId}/...`.
  ///
  /// `productId` may be a temporary id for new products; it does not need to
  /// exist in the database. Only the admin account can write product images
  /// per the Storage rules.
  Future<String> uploadProductImage({
    required String productId,
    required XFile file,
  }) async {
    return _uploadImage(
      file: file,
      path:
          'products/$productId/product_${DateTime.now().millisecondsSinceEpoch}${_extension(file.name)}',
      notEnabledMessage:
          'Firebase Storage is not enabled for this project yet. '
          'Open Firebase Console → Storage → Get started, then try again.',
      failureMessage: 'The product photo could not be uploaded.',
    );
  }

  /// Shared upload flow with validation.
  Future<String> _uploadImage({
    required XFile file,
    required String path,
    required String notEnabledMessage,
    required String failureMessage,
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
          error.code == 'storage/unknown' ||
          error.message?.toLowerCase().contains('bucket') == true) {
        throw StorageServiceException(notEnabledMessage);
      }
      if (error.code == 'unauthorized' ||
          error.code == 'permission-denied') {
        throw const StorageServiceException(
          'Upload blocked by storage rules — sign in as the admin account.',
        );
      }
      throw StorageServiceException(
        error.message ?? failureMessage,
      );
    } catch (error) {
      throw StorageServiceException(
        '$failureMessage $error',
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
