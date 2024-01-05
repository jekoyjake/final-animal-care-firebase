import 'package:animalcare/models/user.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future<String?> getEmail() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String email = user.email!;
        return email;
      } else {
        return " ";
      }
    } catch (e) {
      return e.toString();
    }
  }

  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user != null) {
        print("naa");
        print(user.uid);
        try {
          DocumentSnapshot userSnapshot =
              await userCollection.doc(user.uid).get();
          if (userSnapshot.exists) {
            print(userSnapshot.get('role'));
            // Fetch data and check for nullability
            String uid = user.uid;
            String? email = user.email;
            String firstname = userSnapshot.get('firstname') as String? ?? '';
            String middlename = userSnapshot.get('middlename') as String? ?? '';
            String lastname = userSnapshot.get('lastname') as String? ?? '';
            String address = userSnapshot.get('address') as String? ?? '';
            String contact = userSnapshot.get('contactNo') as String? ?? '';
            String role = userSnapshot.get('role') as String? ?? '';
            String photo = userSnapshot.get('photoUrl') as String? ?? '';

            // Return UserModel instance
            return UserModel(
              email: email,
              uid: uid,
              firstName: firstname,
              middleName: middlename,
              lastName: lastname,
              address: address,
              role: role,
              photoUrl: photo,
              contactNo: contact,
            );
          }
        } on FirebaseException catch (e) {
          print('Error fetching user data: ${e.message}');
        }
      }
      return null;
    });
  }

  String? get uid {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "200";
    } on FirebaseAuthException catch (e) {
      return e.message!;
    }
  }

  Future<String> registerWithEmailAndPassword(
      String email,
      String password,
      String firstname,
      String? middlename,
      String lastname,
      String address,
      String contactNo) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await UserService(uid: userCredential.user!.uid).addUser(
            firstname, middlename, lastname, address, "user", contactNo);
      }

      return "You have successfully registered! ";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } on FirebaseException catch (error) {
      return error.message.toString();
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Create a credential with the user's email and password
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!, password: oldPassword);

        // Reauthenticate the user with the credential
        await user.reauthenticateWithCredential(credential);

        // Update the password
        await user.updatePassword(newPassword);
      } else {
        // Handle the case when the user is not signed in
        print('User is not signed in.');
      }
    } on FirebaseAuthException catch (e) {
      print('Error changing password: ${e.message}');
      rethrow; // Rethrow the exception for higher-level handling
    }
  }

  Future<bool> doesEmailExist(String email) async {
    try {
      var res = await _auth.fetchSignInMethodsForEmail(email);
      if (res.isEmpty) {
        return false;
      }
      return true; // Email exists
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false; // Email does not exist
      } else {
        throw e; // Rethrow other exceptions
      }
    }
  }

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      bool emailExists = await doesEmailExist(email);

      if (emailExists) {
        await _auth.sendPasswordResetEmail(email: email);
        return "Please check your email for a password reset link.";
      } else {
        return "Email not found. Please enter a valid email address.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An unknown error occurred.";
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
