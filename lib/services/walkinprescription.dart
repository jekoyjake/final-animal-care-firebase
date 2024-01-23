import 'package:animalcare/models/walkin_prescription.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalkinPrescriptionService {
  final CollectionReference _walkinPrescriptionsCollection =
      FirebaseFirestore.instance.collection('walkin_prescriptions');

  Future<void> addWalkinPrescription({
    required String walkinpatientUid,
    required String diagnosis,
    required String medicationName,
    required String dosage,
    required String frequency,
    required String doctorUid,
    required DateTime prescriptionDate,
  }) async {
    try {
      await _walkinPrescriptionsCollection.add({
        'walkinpatientUid': walkinpatientUid,
        'diagnosis': diagnosis,
        'medicationName': medicationName,
        'dosage': dosage,
        'frequency': frequency,
        'doctorUid': doctorUid,
        'prescriptionDate': prescriptionDate,
      });
    } catch (e) {
      print('Error adding walk-in prescription: $e');
      throw e;
    }
  }

  Future<List<WalkinInPresciption>> getWalkinPrescriptionsForPatient(
      String patientUid) async {
    try {
      QuerySnapshot querySnapshot = await _walkinPrescriptionsCollection
          .where('walkinpatientUid', isEqualTo: patientUid)
          .get();

      List<WalkinInPresciption> walkinPrescriptions =
          querySnapshot.docs.map((doc) {
        Map<String, dynamic> walkinPrescriptionData =
            doc.data() as Map<String, dynamic>;

        return WalkinInPresciption(
          uid: doc.id,
          walkinpatientUid: walkinPrescriptionData['walkinpatientUid'] ?? '',
          diagnosis: walkinPrescriptionData['diagnosis'] ?? '',
          medicationName: walkinPrescriptionData['medicationName'] ?? '',
          dosage: walkinPrescriptionData['dosage'] ?? '',
          frequency: walkinPrescriptionData['frequency'] ?? '',
          doctorUid: walkinPrescriptionData['doctorUid'] ?? '',
          prescriptionDate: walkinPrescriptionData['prescriptionDate'].toDate(),
        );
      }).toList();

      return walkinPrescriptions;
    } catch (e) {
      print('Error getting walk-in prescriptions for patient: $e');
      throw e;
    }
  }

  // Add more methods for update, delete, and other operations as needed
}
