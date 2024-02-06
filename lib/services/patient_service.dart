import 'package:animalcare/models/patient.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientService {
  final CollectionReference _patientsCollection =
      FirebaseFirestore.instance.collection('patients');

  // Create a new patient record
  Future<void> addPatient(
      String userUid, String petUid, DateTime appointmentDate) async {
    var uidd = _patientsCollection.doc().id;

    PatientModel patient = PatientModel(
        uId: uidd,
        userUid: userUid,
        petUid: petUid,
        appointmentDate: appointmentDate);
    await _patientsCollection.add({
      'userUid': patient.userUid,
      'petUid': patient.petUid,
      'appointmentDate': patient.appointmentDate,
    });
  }

  // Read all patients
  Stream<List<PatientModel>> getAllPatients() {
    return _patientsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return PatientModel(
          uId: doc.id,
          userUid: data['userUid'],
          petUid: data['petUid'],
          appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  // Read a specific patient by UID
  Future<PatientModel?> getPatientByUid(String uid) async {
    DocumentSnapshot snapshot = await _patientsCollection.doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return PatientModel(
        uId: snapshot.id,
        userUid: data['userUid'],
        petUid: data['petUid'],
        appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      );
    } else {
      return null;
    }
  }

  // Update a patient record
  Future<void> updatePatient(PatientModel updatedPatient) async {
    await _patientsCollection.doc(updatedPatient.uId).update({
      'userUid': updatedPatient.userUid,
      'petUid': updatedPatient.petUid,
      'appointmentDate': updatedPatient.appointmentDate,
    });
  }

  // Delete a patient record
  Future<void> deletePatient(String uid) async {
    await _patientsCollection.doc(uid).delete();
  }

  Future<void> deletePatientByPetUid(String petUid) async {
    try {
      // Query patients by petUid
      QuerySnapshot querySnapshot =
          await _patientsCollection.where('petUid', isEqualTo: petUid).get();

      // Iterate through each patient and delete it
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting patients by petUid: $e');
    }
  }
}
