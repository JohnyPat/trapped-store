class AuthRequiredException implements Exception {
  const AuthRequiredException([
    this.message = 'Sign in to continue.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
