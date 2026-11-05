import 'package:firebase_auth/firebase_auth.dart';

abstract final class FirebaseErrorMapper {
  static String auth(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'That email address is not valid.';
        case 'user-disabled':
          return 'This account has been disabled. Contact support.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'An account already exists with that email.';
        case 'weak-password':
          return 'Choose a stronger password (at least 6 characters).';
        case 'too-many-requests':
          return 'Too many attempts. Please wait and try again.';
        case 'requires-recent-login':
          return 'Please sign in again before changing your password.';
        case 'network-request-failed':
          return 'Network unavailable. Check your connection and retry.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }
    if (error is FirebaseException) {
      return error.message ?? 'Firebase request failed. Please try again.';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  static String generic(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '');
    if (text.contains('permission-denied') ||
        text.contains('PERMISSION_DENIED')) {
      return 'You do not have permission to do that.';
    }
    if (text.contains('network')) {
      return 'Network unavailable. Check your connection and retry.';
    }
    return text;
  }
}
