import '../utils/parse.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    this.imageUrl = '',
    this.description = '',
    this.order = 0,
    this.productCount = 0,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int order;
  final int productCount;

  String get label => name.toUpperCase();

  factory Category.fromMap(String id, Map<dynamic, dynamic> map) {
    final data = asStringMap(map);
    return Category(
      id: id,
      name: asString(data['name'], 'UNTITLED'),
      imageUrl: asString(data['imageUrl']),
      description: asString(data['description']),
      order: asInt(data['order']),
      productCount: asInt(data['productCount']),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'imageUrl': imageUrl,
    'description': description,
    'order': order,
    'productCount': productCount,
  };
}
