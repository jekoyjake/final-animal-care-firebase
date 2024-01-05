class PatientModel {
  final String uId;
  final String userUid;
  final String address;
  final String contactNo;
  final String appointmentReason;
  final String petUid;
  final DateTime appointmentDate;

  PatientModel(
      {required this.uId,
      required this.userUid,
      required this.address,
      required this.contactNo,
      required this.appointmentReason,
      required this.petUid,
      required this.appointmentDate});
}
