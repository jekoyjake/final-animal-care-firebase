import 'package:animalcare/models/walkin_patient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalkinService {
  final CollectionReference walkInsCollection =
      FirebaseFirestore.instance.collection('walkins');

  Future<String> addWalkIn(String fullname, String petname, String petspecies,
      String petbreed, String petage, DateTime appointmentDate) async {
    try {
      DocumentReference docRef = await walkInsCollection.add({
        'fullname': fullname,
        'petname': petname,
        'petspecies': petspecies,
        'petbreed': petbreed,
        'petage': petage,
        'appointmentDate': appointmentDate,
      });

      // Return the auto-generated UID
      return docRef.id;
    } catch (e) {
      print('Error adding walk-in: $e');
      return ''; // Return an empty string or handle the error accordingly
    }
  }

  Future<WalkIn?> getWalkInById(String uid) async {
    try {
      DocumentSnapshot walkInSnapshot = await walkInsCollection.doc(uid).get();

      if (walkInSnapshot.exists) {
        Map<String, dynamic> data =
            walkInSnapshot.data() as Map<String, dynamic>;

        return WalkIn(
          uid: walkInSnapshot.id,
          fullname: data['fullname'] ?? '',
          petname: data['petname'] ?? '',
          petspecies: data['petspecies'] ?? '',
          petbreed: data['petbreed'] ?? '',
          petage: data['petage'] ?? '',
          appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
        );
      }

      return null;
    } catch (e) {
      print('Error getting walk-in by ID: $e');
      return null;
    }
  }

  Future<List<WalkIn>> getAllWalkIns() async {
    try {
      QuerySnapshot walkInsSnapshot = await walkInsCollection.get();

      return walkInsSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return WalkIn(
          uid: doc.id,
          fullname: data['fullname'] ?? '',
          petname: data['petname'] ?? '',
          petspecies: data['petspecies'] ?? '',
          petbreed: data['petbreed'] ?? '',
          petage: data['petage'] ?? '',
          appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print('Error getting all walk-ins: $e');
      return [];
    }
  }

  Future<void> updateWalkIn(WalkIn walkIn) async {
    try {
      await walkInsCollection.doc(walkIn.uid).update({
        'fullname': walkIn.fullname,
        'petname': walkIn.petname,
        'petspecies': walkIn.petspecies,
        'petbreed': walkIn.petbreed,
        'petage': walkIn.petage,
        'appointmentDate': walkIn.appointmentDate,
      });
    } catch (e) {
      print('Error updating walk-in: $e');
    }
  }

  Future<void> deleteWalkIn(String uid) async {
    try {
      await walkInsCollection.doc(uid).delete();
    } catch (e) {
      print('Error deleting walk-in: $e');
    }
  }
}
