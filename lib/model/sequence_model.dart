class SequenceModel {
  int? id = 0;

  final int clientId;
  final String clientName;

  final int totalPrice;
  final int profits;
  final int discountPrice;
  final DateTime updateTimeDebts;
  // تاريخ التعديل
  final String updateTimeDebtsUpdate;
  // الحاله ؟تم تعديلها  او لا
  final String status;

  SequenceModel({
    this.id,
    required this.clientId,
    required this.clientName,
    required this.totalPrice,
    required this.updateTimeDebts,
    required this.profits,
    required this.discountPrice,
    required this.updateTimeDebtsUpdate,
    required this.status,
  });

  factory SequenceModel.fromMap(Map<String, dynamic> map) {
    return SequenceModel(
      id: map['id'],
      clientName: map['clientName'],
      clientId: map['clientId'],
      totalPrice: map['total_price'],
      profits: map['profits'],
      updateTimeDebts: DateTime.parse(map['updateTimeDebts']),
      discountPrice: map['discountPrice'],
      updateTimeDebtsUpdate: map['updateTimeDebtsUpdate'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'total_price': totalPrice,
      'profits': profits,
      'updateTimeDebts': updateTimeDebts.toString(),
      'discountPrice': discountPrice,
      'updateTimeDebtsUpdate': updateTimeDebtsUpdate.toString(),
      'status': status,
    };
  }
}
