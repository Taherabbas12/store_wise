class AdminsModel {
  final int id;
  final String userName;
  final String password;
  final String updateTimeDebts;

  AdminsModel({
    required this.id,
    required this.userName,
    required this.password,
    required this.updateTimeDebts,
  });

  factory AdminsModel.fromMap(Map<String, dynamic> map) {
    return AdminsModel(
      id: map['id'],
      userName: map['userName'],
      password: map['password'],
      updateTimeDebts: map['updateTimeDebts'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'password': password,
      'updateTimeDebts': updateTimeDebts,
    };
  }
}
