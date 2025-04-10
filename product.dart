class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
  });

  factory Product.fromMap(Map<String, dynamic> data, String docId) {
    return Product(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'غير محدد',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
    };
  }
}
