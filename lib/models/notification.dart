class NotificationModel {
  String? posterUid;
  bool isAppoinment = false;
  bool isAnnouncment = false;
  bool isMessage = false;
  bool isDoctorAvailable = false;
  bool read = false;
  String? forUserUid;
  String notifMsg;

  NotificationModel(
      {this.posterUid,
      required this.isAppoinment,
      required this.isAnnouncment,
      required this.isDoctorAvailable,
      required this.read,
      required this.isMessage,
      this.forUserUid,
      required this.notifMsg});

  Map<String, dynamic> toMap() {
    return {
      'posterUid': posterUid,
      'isAppointment': isAppoinment,
      'isAnnouncement': isAnnouncment,
      'isMessage': isMessage,
      'isDoctorAvailable': isDoctorAvailable,
      'read': read,
      'forUserUid': forUserUid,
      'notifMsg': notifMsg
    };
  }

  // Named constructor for creating an instance from a map
  NotificationModel.fromMap(Map<String, dynamic> map)
      : posterUid = map['posterUid'],
        isAppoinment = map['isAppoinment'],
        isAnnouncment = map['isAnnouncment'],
        isDoctorAvailable = map['isDoctorAvailable'],
        read = map['read'],
        isMessage = map['isMessage'],
        forUserUid = map['forUserUid'],
        notifMsg = map['notifMsg'];
}
