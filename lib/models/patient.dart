class PatientModel {
  final String uId;
  final String userUid;
  final String petUid;
  final DateTime appointmentDate;

  PatientModel(
      {required this.uId,
      required this.userUid,
      required this.petUid,
      required this.appointmentDate});
}
