class UserModel {
  final String uid;
  final String firstname;
  final String? middlename;
  final String lastname;
  final String? email;
  final String address;
  final String contactNo;
  final String role;
  String? photoUrl;

  UserModel(
      {required this.email,
      required this.uid,
      required this.firstname,
      this.middlename,
      required this.lastname,
      required this.address,
      required this.contactNo,
      required this.role,
      this.photoUrl});
}
