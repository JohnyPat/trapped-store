abstract final class AppConstants {
  static const String appName = '[trapped]';
  static const String tagline = 'WEAR YOUR CONVICTION.';
  static const String currencyCode = 'PHP';
  static const String currencySymbol = 'PHP';
  static const double defaultShippingFee = 150;
  static const double freeShippingThreshold = 3000;
  static const String supportEmail = 'orders@wearetrapped.com';
  static const String hostingOrigin = 'https://trapped-56f3e.web.app';

  static const List<String> sizes = ['XS', 'S', 'M', 'L', 'XL', '2XL'];

  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];
}
