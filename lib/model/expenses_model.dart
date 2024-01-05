class ExpenseData {
  final int id;
  final String nameExpenses;
  final String typeExpenses;
  final String eventDetails;
  final int priceExpenses;
  final String time;
  final String timeFilter;

  ExpenseData({
    required this.id,
    required this.nameExpenses,
    required this.typeExpenses,
    required this.eventDetails,
    required this.priceExpenses,
    required this.time,
    required this.timeFilter,
  });

  factory ExpenseData.fromMap(Map<String, dynamic> map) {
    return ExpenseData(
      id: map['id'],
      nameExpenses: map['nameExpenses'],
      typeExpenses: map['typeExpenses'],
      eventDetails: map['eventDetails'],
      priceExpenses: map['priceExpenses'],
      time: map['time'],
      timeFilter: map['timeFilter'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'nameExpenses': nameExpenses,
      'typeExpenses': typeExpenses,
      'eventDetails': eventDetails,
      'priceExpenses': priceExpenses,
      'time': time,
      'timeFilter': timeFilter,
    };
  }
}
