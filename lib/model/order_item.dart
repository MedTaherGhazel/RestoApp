class OrderItem {
  final String idOrder;
  final String nameOrder;
  final String photoOrder;
  final String quantityOrder;
  final String priceOrder;


  OrderItem({
    required this.idOrder,
    required this.nameOrder,
    required this.photoOrder,
    required this.priceOrder,
    required this.quantityOrder,

  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      idOrder: json['id'] ?? '',
      nameOrder: json['name'] ?? '',
      photoOrder: json['photo'] ?? '',
      priceOrder: json['price'] ?? '',
      quantityOrder:  json['quantity'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idOrder,
      'name': nameOrder,
      'photo': photoOrder,
      'quantity': quantityOrder,
      'price': priceOrder,
    };
  }
}
