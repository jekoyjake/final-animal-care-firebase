class AppointmentModel {
  final String uid;
  final DateTime appointmentDate;
  final String petId;
  final String? status;
  bool seen = false;
  String? userUid;

  AppointmentModel({
    required this.uid,
    required this.userUid,
    required this.appointmentDate,
    this.status,
    required this.seen,
    required this.petId,
  });
}
