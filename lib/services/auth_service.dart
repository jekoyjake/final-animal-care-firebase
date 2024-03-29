import 'dart:core';

import 'package:animalcare/models/user.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  Future<String?> getEmailByUid(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await userCollection.doc(uid).get();
      if (kDebugMode) {
        print(userSnapshot.data());
      }

      if (userSnapshot.exists) {
        String email = userSnapshot.get('email');
        return email;
      } else {
        return null; // User with the provided UID not found
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting email by UID: $e");
      }
      return null;
    }
  }

  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user != null) {
        try {
          DocumentSnapshot userSnapshot =
              await userCollection.doc(user.uid).get();
          if (userSnapshot.exists) {
            String uid = user.uid;
            String? email = user.email;
            String firstname = userSnapshot.get('firstname') as String? ?? '';
            String middlename = userSnapshot.get('middlename') as String? ?? '';
            String lastname = userSnapshot.get('lastname') as String? ?? '';
            String address = userSnapshot.get('address') as String? ?? '';
            String contact = userSnapshot.get('contactNo') as String? ?? '';
            String role = userSnapshot.get('role') as String? ?? '';
            String photo = userSnapshot.get('photoUrl') as String? ?? '';
            bool isOn = userSnapshot.get('isOnline');

            // Return UserModel instance
            return UserModel(
              email: email,
              uid: uid,
              firstname: firstname,
              middlename: middlename,
              lastname: lastname,
              address: address,
              role: role,
              photoUrl: photo,
              contactNo: contact,
              isOnline: isOn,
            );
          }
        } on FirebaseException catch (e) {
          if (kDebugMode) {
            print('Error fetching user data: ${e.message}');
          }
        }
      }
      return null;
    });
  }

  Future<String> getUserByUid(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await userCollection.doc(uid).get();

      if (userSnapshot.exists) {
        String firstname = userSnapshot['firstname'];

        return "$firstname $firstname "; // or return any other data you need
      } else {
        // User with the provided UID not found
        return "User";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting user by UID: $e");
      }
      return e.toString();
    }
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
      final UserService userService = UserService(uid: _auth.currentUser!.uid);
      await userService.updateUserOnlineStatus(true);
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

  Future<String> addDoctor(
    String email,
    String password,
    String firstname,
    String? middlename,
    String lastname,
    String address,
    String contactNo,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await UserService(uid: userCredential.user!.uid).addUser(
          firstname,
          "middlename",
          lastname,
          address,
          "doctor",
          contactNo,
        );
      }

      return "You have successfully added a doctor!";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } on FirebaseException catch (error) {
      return error.message.toString();
    }
  }

  Future<String> addStaff(
    String email,
    String password,
    String firstname,
    String? middlename,
    String lastname,
    String address,
    String contactNo,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await UserService(uid: userCredential.user!.uid).addUser(
          firstname,
          "middlename",
          lastname,
          address,
          "staff",
          contactNo,
        );
      }

      return "You have successfully added a staff!";
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
        if (kDebugMode) {
          print('User is not signed in.');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Error changing password: ${e.message}');
      }
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
        rethrow; // Rethrow other exceptions
      }
    }
  }

  Future<String> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
    return "Please check your email for a password reset link.";
  }

  Future<void> signOut() async {
    final UserService userService = UserService(uid: _auth.currentUser!.uid);
    try {
      await userService.updateUserOnlineStatus(false);

      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }

  Future<String?> getUidByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot =
          await userCollection.where('email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0].id;
      } else {
        return null; // Email not found
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting UID by email: $e');
      }
      return null;
    }
  }
}
