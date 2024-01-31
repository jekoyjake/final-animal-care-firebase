import 'package:animalcare/models/prescription.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionService {
  final CollectionReference _prescriptionsCollection =
      FirebaseFirestore.instance.collection('prescriptions');

  Future<void> addPrescription({
    required String diagnosis,
    required String medicationName,
    required String dosage,
    required String frequency,
    required String petUid,
    required String doctorUid,
    required String prescriptionDate,
  }) async {
    try {
      await _prescriptionsCollection.add({
        'diagnosis': diagnosis,
        'medicationName': medicationName,
        'dosage': dosage,
        'frequency': frequency,
        'petUid': petUid,
        'doctorUid': doctorUid,
        'prescriptionDate': prescriptionDate
      });
    } catch (e) {
      print('Error adding prescription: $e');
      throw e;
    }
  }

  Future<List<Prescription>> getPrescriptionsForPet(String petUid) async {
    try {
      QuerySnapshot querySnapshot = await _prescriptionsCollection
          .where('petUid', isEqualTo: petUid)
          .get();

      List<Prescription> prescriptions = querySnapshot.docs.map((doc) {
        Map<String, dynamic> prescriptionData =
            doc.data() as Map<String, dynamic>;

        return Prescription(
          id: doc.id,
          dianosis: prescriptionData['diagnosis'] ?? '',
          medicationName: prescriptionData['medicationName'] ?? '',
          dosage: prescriptionData['dosage'] ?? '',
          frequency: prescriptionData['frequency'] ?? '',
          petUid: prescriptionData['petUid'] ?? '',
          doctorUid: prescriptionData['doctorUid'] ?? '',
          prescriptionDate: prescriptionData['prescriptionDate'] ?? '',
        );
      }).toList();

      return prescriptions;
    } catch (e) {
      print('Error getting prescriptions for pet: $e');
      throw e;
    }
  }

  Future<Prescription?> viewPrescriptionByUid(String PetUid) async {
    try {
      QuerySnapshot querySnapshot = await _prescriptionsCollection
          .where('petUid', isEqualTo: PetUid)
          .limit(1) // Limit to 1 document since we only need one prescription
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If there's at least one prescription
        Map<String, dynamic> prescriptionData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;

        return Prescription(
          id: querySnapshot.docs.first.id,
          dianosis: prescriptionData['diagnosis'] ?? '',
          medicationName: prescriptionData['medicationName'] ?? '',
          dosage: prescriptionData['dosage'] ?? '',
          frequency: prescriptionData['frequency'] ?? '',
          petUid: prescriptionData['petUid'] ?? '',
          doctorUid: prescriptionData['doctorUid'] ?? '',
          prescriptionDate: prescriptionData['prescriptionDate'] ?? '',
        );
      } else {
        // If no prescription found
        return null;
      }
    } catch (e) {
      print('Error viewing prescription by petUid: $e');
      throw e;
    }
  }

  // Add more methods for update, delete, and other operations as needed
}
