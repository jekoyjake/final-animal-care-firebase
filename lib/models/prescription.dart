class Prescription {
  final String id;
  final String dianosis;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String petUid;
  final String doctorUid;
  final DateTime prescriptionDate;

  Prescription({
    required this.id,
    required this.dianosis,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.petUid,
    required this.doctorUid,
    required this.prescriptionDate,
  });
}
