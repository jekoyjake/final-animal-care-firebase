import 'dart:async';

import 'package:animalcare/models/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('notification');

  Future<NotificationModel?> addAppointmentNotification(
      String fromId, String userId, String msg) async {
    final notif = NotificationModel(
      posterUid: fromId,
      isAppoinment: true,
      isAnnouncment: false,
      read: false,
      forUserUid: userId,
      notifMsg: msg,
    );

    try {
      final DocumentReference docRef =
          await _collectionReference.add(notif.toMap());

      // Retrieve the added document from Firestore
      final DocumentSnapshot snapshot = await docRef.get();

      // Create a NotificationModel from the retrieved data
      final NotificationModel addedNotification =
          NotificationModel.fromMap(snapshot.data() as Map<String, dynamic>);

      // Return the added NotificationModel
      return addedNotification;
    } catch (error) {
      print('Error adding notification: $error');
      return null;
    }
  }

  Stream<List<NotificationModel>> getMyNotifStream(String userId) {
    return _collectionReference
        .where('forUserUid', isEqualTo: userId)
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs
          .map((doc) =>
              NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
