class Product {
  int? id;
  String name;
  String category;
  int stock;
  double buyPrice;
  double sellPrice;
  String? imagePath;
  String createdAt;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.stock,
    required this.buyPrice,
    required this.sellPrice,
    this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'stock': stock,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'image_path': imagePath,
      'created_at': createdAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      stock: map['stock'],
      buyPrice: map['buy_price'],
      sellPrice: map['sell_price'],
      imagePath: map['image_path'],
      createdAt: map['created_at'],
    );
  }
}