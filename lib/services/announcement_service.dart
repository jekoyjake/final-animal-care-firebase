import 'dart:typed_data';
import 'package:animalcare/models/announcement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementService {
  final CollectionReference _announcementCollection =
      FirebaseFirestore.instance.collection('announcements');

  Future<void> addAnnouncement({
    required String ownerUid,
    required String title,
    required String content,
    Uint8List? imageBytes,
  }) async {
    try {
      await _announcementCollection.add({
        'ownerUid': ownerUid,
        'title': title,
        'content': content,
      });
    } catch (e) {
      print('Error adding announcement: $e');
      rethrow;
    }
  }

  Future<void> updateAnnouncement({
    required String announcementId,
    required String ownerUid,
    required String title,
    required String content,
  }) async {
    try {
      await _announcementCollection.doc(announcementId).update({
        'ownerUid': ownerUid,
        'title': title,
        'content': content,
      });
    } catch (e) {
      print('Error updating announcement: $e');
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _announcementCollection.doc(announcementId).delete();
    } catch (e) {
      print('Error deleting announcement: $e');
      rethrow;
    }
  }

  Future<List<Announcement>> getAllAnnouncements() async {
    try {
      QuerySnapshot querySnapshot = await _announcementCollection.get();

      List<Announcement> announcements = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data =
            doc.data() as Map<String, dynamic>; // Adjust per your structure
        return Announcement(
          uid: doc.id,
          ownerUid: data['ownerUid'] ?? '',
          title: data['title'] ?? '',
          content: data['content'] ?? '',
        );
      }).toList();

      return announcements;
    } catch (e) {
      print('Error getting all announcements: $e');
      throw e;
    }
  }

  Future<List<Announcement>> getMyAnnouncements(String ownerUid) async {
    try {
      QuerySnapshot querySnapshot = await _announcementCollection
          .where('ownerUid', isEqualTo: ownerUid)
          .get();

      List<Announcement> announcements = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data =
            doc.data() as Map<String, dynamic>; // Adjust per your structure
        return Announcement(
          uid: doc.id,
          ownerUid: data['ownerUid'] ?? '',
          title: data['title'] ?? '',
          content: data['content'] ?? '',
        );
      }).toList();

      return announcements;
    } catch (e) {
      print('Error getting my announcements: $e');
      throw e;
    }
  }
}
