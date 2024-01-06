import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String uId;
  final String userUid;
  final String petUid;
  final DateTime appointmentDate;

  PatientModel({
    required this.uId,
    required this.userUid,
    required this.petUid,
    required this.appointmentDate,
  });

  factory PatientModel.fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PatientModel(
      uId: doc.id,
      userUid: data['userUid'] ?? '',
      petUid: data['petUid'] ?? '',
      appointmentDate:
          (data['appointmentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
