import 'package:animalcare/models/patient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientService {
  final CollectionReference _patientsCollection =
      FirebaseFirestore.instance.collection('patients');

  // Create a new patient record
  Future<void> addPatient(PatientModel patient) async {
    await _patientsCollection.add({
      'userUid': patient.userUid,
      'address': patient.address,
      'contactNo': patient.contactNo,
      'appointmentReason': patient.appointmentReason,
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
          address: data['address'],
          contactNo: data['contactNo'],
          appointmentReason: data['appointmentReason'],
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
        address: data['address'],
        contactNo: data['contactNo'],
        appointmentReason: data['appointmentReason'],
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
      'address': updatedPatient.address,
      'contactNo': updatedPatient.contactNo,
      'appointmentReason': updatedPatient.appointmentReason,
      'petUid': updatedPatient.petUid,
      'appointmentDate': updatedPatient.appointmentDate,
    });
  }

  // Delete a patient record
  Future<void> deletePatient(String uid) async {
    await _patientsCollection.doc(uid).delete();
  }
}
