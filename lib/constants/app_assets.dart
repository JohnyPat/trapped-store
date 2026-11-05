/// Local assets are bundled for instant first paint and as an offline fallback.
/// Firebase product records remain the source of truth for the catalogue.
abstract final class AppAssets {
  static const String hero = 'assets/images/editorial/pic1.png';
  static const String forest = 'assets/images/editorial/forest.jpg';
  static const String logoWordmark = 'assets/images/brand/logo_wordmark.png';
  static const String logoMark = 'assets/images/brand/logo_mark.png';
  static const String aboutUs = 'assets/images/editorial/about_us.png';
  static const String sizeChart = 'assets/images/editorial/size_chart.png';
  static const String editorialOne = 'assets/images/editorial/pic2.png';
  static const String editorialTwo = 'assets/images/editorial/pic3.png';
  static const String editorialThree = 'assets/images/editorial/pic4.png';
  static const String editorialFour = 'assets/images/editorial/pic5.png';

  static const Map<String, String> categoryImages = {
    'all': 'assets/images/editorial/category_all.png',
    'cat-shirts': 'assets/images/editorial/category_shirts.png',
    'cat-pants': 'assets/images/editorial/category_pants.png',
    'cat-headwear': 'assets/images/editorial/category_headwear.png',
  };

  static const Map<String, String> productImages = {
    'praise-the-lord': 'assets/images/products/praise-the-lord.png',
    'we-are-fucked': 'assets/images/products/we-are-fucked.png',
    'pistol-tee': 'assets/images/products/pistol-tee.png',
    'cruzifix-tee': 'assets/images/products/cruzifix-tee.png',
    'leopard-shorts': 'assets/images/products/leopard-shorts.png',
    'fleece-shorts': 'assets/images/products/fleece-shorts.png',
    'check-shorts': 'assets/images/products/check-shorts.png',
    'real-tree-shorts': 'assets/images/products/real-tree-shorts.png',
    'leo-jorts-brown': 'assets/images/products/leo-jorts-brown.png',
    'leo-jorts-white': 'assets/images/products/leo-jorts-white.png',
    '666-cap': 'assets/images/products/666-cap.png',
    'mauve-cap': 'assets/images/products/mauve-cap.png',
  };

  static String fallbackForProduct(String id) =>
      productImages[id] ?? 'assets/images/products/praise-the-lord.png';
}
