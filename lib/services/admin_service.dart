import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthService authService = AuthService();

  Future<void> addDoctor(
    String firstname,
    String? middlename,
    String lastname,
    String address,
    String role,
    String contactNo,
  ) async {
    await UserService(uid: _auth.currentUser!.uid)
        .addUser(firstname, middlename, lastname, address, role, contactNo);
  }
}
