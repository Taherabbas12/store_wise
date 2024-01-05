class BarcodeData {
  final int id;
  final int productsId;
  final String barcode;

  BarcodeData({
    required this.id,
    required this.productsId,
    required this.barcode,
  });

  Map<String, dynamic> toMap() {
    return {
      'productsId': productsId,
      'barcode': barcode,
    };
  }
}
