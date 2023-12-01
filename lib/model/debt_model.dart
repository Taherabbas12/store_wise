class DebtModel {
  int clientId; // تغيير هنا
  double debtAmount;
  DateTime debtDate;

  String notes;

  DebtModel({
    required this.clientId,
    required this.debtAmount,
    required this.debtDate,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId, // تغيير هنا
      'debtAmount': debtAmount,
      'debtDate': debtDate.toIso8601String(),

      'notes': notes,
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      clientId: map['clientId'], // تغيير هنا
      debtAmount: map['debtAmount'],
      debtDate: DateTime.parse(map['debtDate']),

      notes: map['notes'],
    );
  }
}
