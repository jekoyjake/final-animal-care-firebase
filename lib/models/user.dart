class UserModel {
  final String uid;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? email;
  final String address;
  final String contactNo;
  final String role;
  String? photoUrl;

  UserModel(
      {required this.email,
      required this.uid,
      required this.firstName,
      this.middleName,
      required this.lastName,
      required this.address,
      required this.contactNo,
      required this.role,
      this.photoUrl});
}
