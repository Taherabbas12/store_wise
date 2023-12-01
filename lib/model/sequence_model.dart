class SequenceModel {
  int id = 0;

  final int clientId;

  final int totalPrice;
  final String updateTimeDebts;

  SequenceModel({
    required this.clientId,
    required this.totalPrice,
    required this.updateTimeDebts,
  });

  factory SequenceModel.fromMap(Map<String, dynamic> map) {
    return SequenceModel(
      clientId: map['clientId'],
      totalPrice: map['total_price'],
      updateTimeDebts: map['updateTimeDebts'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'total_price': totalPrice,
      'updateTimeDebts': updateTimeDebts,
    };
  }
}
