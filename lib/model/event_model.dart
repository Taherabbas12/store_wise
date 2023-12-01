class EventsModel {
  int? id;
  final int adminId;
  final String eventType;
  final String eventDetails;
  final String time;

  EventsModel({
    required this.adminId,
    required this.eventType,
    required this.eventDetails,
    required this.time,
  });

  factory EventsModel.fromMap(Map<String, dynamic> map) {
    return EventsModel(
      adminId: map['adminId'],
      eventType: map['eventType'],
      eventDetails: map['eventDetails'],
      time: map['time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'eventType': eventType,
      'eventDetails': eventDetails,
      'time': time,
    };
  }
}
