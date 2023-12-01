class AccountModel {
  int id;
  String name;
  String storeName;
  String phoneNumber;
  int debts;
  DateTime updateTimeDebts;

  AccountModel({
    required this.id,
    required this.name,
    required this.storeName,
    required this.phoneNumber,
    required this.debts,
    required this.updateTimeDebts,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'storeName': storeName,
      'phoneNumber': phoneNumber,
      'debts': debts,
      'updateTimeDebts': updateTimeDebts.toIso8601String(),
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      name: map['name'],
      storeName: map['storeName'],
      phoneNumber: map['phoneNumber'],
      debts: map['debts'],
      updateTimeDebts: DateTime.parse(map['updateTimeDebts']),
    );
  }
}
