class BasketClientModel {
  late int id;

  int sequenceId;
  final String nameProduct;
  int requiredQuantity;
  int price;
  int totalPrice;
  int totalPriceProfits;
  String note;

  BasketClientModel({
    required this.sequenceId,
    required this.nameProduct,
    required this.requiredQuantity,
    required this.price,
    required this.totalPrice,
    required this.note,
    required this.totalPriceProfits,
  });

  factory BasketClientModel.fromMap(Map<String, dynamic> map) {
    return BasketClientModel(
      sequenceId: map['sequenceId'] ?? 0,
      nameProduct: map['nameProduct'],
      requiredQuantity: map['requiredQuantity'],
      price: map['price'],
      totalPrice: map['totalPrice'],
      note: map['note'],
      totalPriceProfits: map['totalPriceProfits'],
    );
  }
  factory BasketClientModel.fromMap2(Map<String, dynamic> map) {
    BasketClientModel t = BasketClientModel(
      sequenceId: map['sequenceId'] ?? 0,
      nameProduct: map['nameProduct'],
      requiredQuantity: map['requiredQuantity'],
      price: map['price'],
      totalPrice: map['totalPrice'],
      note: map['note'],
      totalPriceProfits: map['totalPriceProfits'],
    );
    t.id = map['id'] ?? 0;
    return t;
  }

  Map<String, dynamic> toMap() {
    return {
      'sequenceId': sequenceId,
      'nameProduct': nameProduct,
      'requiredQuantity': requiredQuantity,
      'price': price,
      'totalPrice': totalPrice,
      'note': note,
      'totalPriceProfits': totalPriceProfits,
    };
  }
}
