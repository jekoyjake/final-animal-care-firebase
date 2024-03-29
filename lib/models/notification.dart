import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? posterUid;
  bool isAppoinment;
  bool isAnnouncment;
  bool read;
  String? forUserUid;
  String notifMsg;

  NotificationModel({
    this.posterUid,
    required this.isAppoinment,
    required this.isAnnouncment,
    required this.read,
    this.forUserUid,
    required this.notifMsg,
  });

  Map<String, dynamic> toMap() {
    return {
      'posterUid': posterUid,
      'isAppoinment': isAppoinment,
      'isAnnouncment': isAnnouncment,
      'read': read,
      'forUserUid': forUserUid,
      'notifMsg': notifMsg,
    };
  }

  // Named constructor for creating an instance from a map
  NotificationModel.fromMap(Map<String, dynamic> map)
      : posterUid = map['posterUid'],
        isAppoinment = map['isAppoinment'],
        isAnnouncment = map['isAnnouncment'],
        read = map['read'],
        forUserUid = map['forUserUid'],
        notifMsg = map['notifMsg'];
}
