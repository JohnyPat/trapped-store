import '../constants/app_assets.dart';
import '../utils/parse.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.stock,
    this.compareAtPrice,
    this.images = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.featured = false,
    this.isNew = false,
    this.active = true,
    this.sku = '',
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final double? compareAtPrice;
  final String imageUrl;
  final List<String> images;
  final String categoryId;
  final int stock;
  final double rating;
  final int reviewCount;
  final List<String> sizes;
  final bool featured;
  final bool isNew;
  final bool active;
  final String sku;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get inStock => stock > 0;
  bool get isLowStock => stock > 0 && stock <= 5;
  bool get onSale =>
      compareAtPrice != null && compareAtPrice! > price;

  List<String> get gallery {
    final result = <String>[];
    if (imageUrl.isNotEmpty) result.add(imageUrl);
    for (final image in images) {
      if (image.isNotEmpty && !result.contains(image)) result.add(image);
    }
    return result;
  }

  String get localFallback => AppAssets.fallbackForProduct(id);

  factory Product.fromMap(String id, Map<dynamic, dynamic> map) {
    final data = asStringMap(map);
    final rawSizes = asStringList(data['sizes']);
    return Product(
      id: id,
      name: asString(data['name'], 'UNTITLED PRODUCT'),
      description: asString(data['description']),
      price: asDouble(data['price']),
      compareAtPrice: data['compareAtPrice'] == null
          ? null
          : asDouble(data['compareAtPrice']),
      imageUrl: asString(data['imageUrl']),
      images: asStringList(data['images']),
      categoryId: asString(data['categoryId']),
      stock: asInt(data['stock']),
      rating: asDouble(data['rating']),
      reviewCount: asInt(data['reviewCount']),
      sizes: rawSizes.isEmpty
          ? const ['S', 'M', 'L', 'XL']
          : rawSizes,
      featured: asBool(data['featured']),
      isNew: asBool(data['isNew']),
      active: asBool(data['active'], true),
      sku: asString(data['sku']),
      sortOrder: asInt(data['sortOrder']),
      createdAt: asDate(data['createdAt']),
      updatedAt: asDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'compareAtPrice': compareAtPrice,
    'imageUrl': imageUrl,
    'images': images,
    'categoryId': categoryId,
    'stock': stock,
    'rating': rating,
    'reviewCount': reviewCount,
    'sizes': sizes,
    'featured': featured,
    'isNew': isNew,
    'active': active,
    'sku': sku,
    'sortOrder': sortOrder,
    'createdAt': createdAt?.millisecondsSinceEpoch,
    'updatedAt': DateTime.now().millisecondsSinceEpoch,
  };

  Product copyWith({
    String? name,
    String? description,
    double? price,
    double? compareAtPrice,
    String? imageUrl,
    List<String>? images,
    String? categoryId,
    int? stock,
    double? rating,
    int? reviewCount,
    List<String>? sizes,
    bool? featured,
    bool? isNew,
    bool? active,
    String? sku,
    int? sortOrder,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      sizes: sizes ?? this.sizes,
      featured: featured ?? this.featured,
      isNew: isNew ?? this.isNew,
      active: active ?? this.active,
      sku: sku ?? this.sku,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
