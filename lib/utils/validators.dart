abstract final class Validators {
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? fullName(String? value) {
    final base = required(value, field: 'Full name');
    if (base != null) return base;
    if (value!.trim().length < 2) return 'Enter your full name';
    return null;
  }

  static String? email(String? value) {
    final base = required(value, field: 'Email');
    if (base != null) return base;
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(value!.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value) {
    final base = required(value, field: 'Phone number');
    if (base != null) return base;
    final digits = value!.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.length < 7) return 'Enter a valid phone number';
    return null;
  }

  static String? password(String? value) {
    final base = required(value, field: 'Password');
    if (base != null) return base;
    if (value!.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final base = required(value, field: 'Confirm password');
    if (base != null) return base;
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? address(String? value) {
    final base = required(value, field: 'Delivery address');
    if (base != null) return base;
    if (value!.trim().length < 8) return 'Enter a complete delivery address';
    return null;
  }

  static String? postalCode(String? value) {
    final base = required(value, field: 'Postal code');
    if (base != null) return base;
    if (value!.trim().length < 3) return 'Enter a valid postal code';
    return null;
  }
}
