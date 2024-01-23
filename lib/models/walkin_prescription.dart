class WalkinInPresciption {
  final String uid;
  final String walkinpatientUid;
  final String diagnosis;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String doctorUid;
  final DateTime prescriptionDate;

  WalkinInPresciption(
      {required this.uid,
      required this.walkinpatientUid,
      required this.diagnosis,
      required this.medicationName,
      required this.dosage,
      required this.frequency,
      required this.doctorUid,
      required this.prescriptionDate});
}
