class Transaction {
  int? id;
  int productId;
  int quantity;
  double totalPrice;
  String date;
  String? productName;
  double? buyPrice;
  double? sellPrice;

  Transaction({
    this.id,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.date,
    this.productName,
    this.buyPrice,
    this.sellPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'date': date,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      totalPrice: map['total_price'],
      date: map['date'],
      productName: map['product_name'],
      buyPrice: map['buy_price'],
      sellPrice: map['sell_price'],
    );
  }
}