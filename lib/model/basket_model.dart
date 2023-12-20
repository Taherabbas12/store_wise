class BasketModel {
  late String nameProduct;
  late int requiredQuantity;
  late int price;
  late int totalPrice;
  int totalPriceProfits;
  late String note;
  late int id;
  int idBasket;

  BasketModel({
    required this.id,
    required this.nameProduct,
    required this.requiredQuantity,
    required this.price,
    required this.totalPrice,
    required this.note,
    required this.idBasket,
    required this.totalPriceProfits,
  });

  // تحويل البيانات إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id_basket': idBasket,
      'nameProduct': nameProduct,
      'requiredQuantity': requiredQuantity,
      'price': price,
      'totalPrice': totalPrice,
      'note': note,
      'totalPriceProfits': totalPriceProfits,
    };
  }

  // تحويل Map إلى كائن BasketModel
  static BasketModel fromMap(Map<String, dynamic> map) {
    return BasketModel(
      id: map['id'],
      idBasket: map['id_basket'],
      nameProduct: map['nameProduct'],
      requiredQuantity: map['requiredQuantity'],
      price: map['price'],
      totalPrice: map['totalPrice'],
      note: map['note'],
      totalPriceProfits: map['totalPriceProfits'],
    );
  }
}
