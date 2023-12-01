class Product {
  late int id;
  late String nameProduct;
  late int quantity;
  late int sellingPrice;
  late int purchasingPrice;
  late String description;
  late String note;

  Product({
    required this.id,
    required this.nameProduct,
    required this.quantity,
    required this.sellingPrice,
    required this.purchasingPrice,
    required this.description,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'nameProduct': nameProduct,
      'quantity': quantity,
      'sellingPrice': sellingPrice,
      'purchasingPrice': purchasingPrice,
      'description': description,
      'note': note,
    };
  }
}
