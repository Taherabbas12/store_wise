class BasketClientModel {
  late int id;

  final int sequenceId;
  final String nameProduct;
  final int requiredQuantity;
  final int price;
  final int totalPrice;
  final String note;

  BasketClientModel({
    required this.sequenceId,
    required this.nameProduct,
    required this.requiredQuantity,
    required this.price,
    required this.totalPrice,
    required this.note,
  });

  factory BasketClientModel.fromMap(Map<String, dynamic> map) {
    return BasketClientModel(
      sequenceId: map['sequenceId'],
      nameProduct: map['nameProduct'],
      requiredQuantity: map['requiredQuantity'],
      price: map['price'],
      totalPrice: map['totalPrice'],
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sequenceId': sequenceId,
      'nameProduct': nameProduct,
      'requiredQuantity': requiredQuantity,
      'price': price,
      'totalPrice': totalPrice,
      'note': note,
    };
  }
}
