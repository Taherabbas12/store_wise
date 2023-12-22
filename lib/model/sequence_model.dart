class SequenceModel {
  int? id = 0;

  final int clientId;

  final int totalPrice;
  final int profits;
  final DateTime updateTimeDebts;

  SequenceModel({
    this.id,
    required this.clientId,
    required this.totalPrice,
    required this.updateTimeDebts,
    required this.profits,
  });

  factory SequenceModel.fromMap(Map<String, dynamic> map) {
    return SequenceModel(
      id: map['id'],
      clientId: map['clientId'],
      totalPrice: map['total_price'],
      profits: map['profits'],
      updateTimeDebts: DateTime.parse(map['updateTimeDebts']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'total_price': totalPrice,
      'profits': profits,
      'updateTimeDebts': updateTimeDebts.toString(),
    };
  }
}
