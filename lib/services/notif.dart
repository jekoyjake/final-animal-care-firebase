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

      // Check if the data retrieved from Firestore is not null
      if (snapshot.data() != null) {
        // Create a NotificationModel from the retrieved data
        final NotificationModel addedNotification =
            NotificationModel.fromMap(snapshot.data()! as Map<String, dynamic>);

        // Return the added NotificationModel
        return addedNotification;
      } else {
        print('Error adding notification: Document data is null');
        return null;
      }
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
          .map((doc) {
            // Use null-aware operator to check for null before creating NotificationModel
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
            return data != null ? NotificationModel.fromMap(data) : null;
          })
          // Use where to filter out null values
          .whereType<NotificationModel>() // Filter out null values
          .toList();
    });
  }

  Stream<List<NotificationModel>> getNotifForAppointment() {
    return _collectionReference
        .where('isAppoinment', isEqualTo: true)
        .where('forUserUid', isEqualTo: 'userId')
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs
          .map((doc) {
            // Use null-aware operator to check for null before creating NotificationModel
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
            return data != null ? NotificationModel.fromMap(data) : null;
          })
          // Use where to filter out null values
          .whereType<NotificationModel>() // Filter out null values
          .toList();
    });
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _collectionReference
          .where('forUserUid', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      // Return the count of unread notifications
      return querySnapshot.size;
    } catch (error) {
      print('Error getting unread notification count: $error');
      return 0; // Return 0 in case of an error
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _collectionReference
          .where('forUserUid', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Update each notification to mark it as read
        await doc.reference.update({'read': true});
      }
    } catch (error) {
      print('Error marking notifications as read: $error');
    }
  }

  Future<void> deleteAllNotificationsByUserId(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _collectionReference
          .where('forUserUid', isEqualTo: userId)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Delete each notification
        await doc.reference.delete();
      }
    } catch (error) {
      print('Error deleting notifications: $error');
    }
  }
}
