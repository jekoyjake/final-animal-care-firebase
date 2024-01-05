import 'dart:typed_data';

import 'package:animalcare/models/user.dart';
import 'package:animalcare/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  final String uid;

  UserService({required this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  final ChatService chatService = ChatService();

  Future<Map<String, String>> getUserById(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await userCollection.doc(userId).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        String firstName = userData['firstname'] ?? '';
        String lastName = userData['lastname'] ?? '';

        return {
          'firstName': firstName,
          'lastName': lastName,
        };
      } else {
        return {
          'firstName': '',
          'lastName': '',
        };
      }
    } catch (e) {
      print('Error getting user by ID: $e');
      throw e;
    }
  }

  Stream<UserModel?> getUser() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((userSnapshot) {
      if (userSnapshot.exists) {
        String email = userSnapshot.get('email') as String;
        String firstName = userSnapshot.get('firstname') as String;
        String? middleName = userSnapshot.get('middlename') as String?;
        String lastName = userSnapshot.get('lastname') as String;
        String address = userSnapshot.get('address') as String;
        String contactNo = userSnapshot.get('contactNo') as String;
        String role = userSnapshot.get('role') as String;
        String? photoUrl = userSnapshot.get('photoUrl') as String?;

        return UserModel(
          email: email,
          uid: uid,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          address: address,
          role: role,
          photoUrl: photoUrl,
          contactNo: contactNo,
        );
      } else {
        return null;
      }
    });
  }

  Future<void> addUser(String firstname, String? middlename, String lastname,
      String address, String role, String contactNo) async {
    try {
      // Prepare data to update
      Map<String, dynamic> userData = {
        'firstname': firstname,
        'lastname': lastname,
        'address': address,
        'role': role,
        'contactNo': contactNo,
        'photoUrl': ''
      };

      // Add middlename to userData if it's not null or empty
      if (middlename != null && middlename.isNotEmpty) {
        userData['middlename'] = middlename;
      }

      // Update user data in Firestore
      await userCollection.doc(uid).set(userData);
    } on FirebaseException catch (e) {
      print(e.message);
      // Handle the FirebaseException according to your application's logic
    }
  }

  Future<String?> _uploadImage(Uint8List imageBytes) async {
    try {
      // Get a reference to the location where we'll store the file in Firebase Storage
      Reference storageReference =
          FirebaseStorage.instance.ref().child('user_images/$uid.png');

      // Create metadata for the file
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpg');

      // Upload the bytes to Firebase Storage with specified metadata
      await storageReference.putData(imageBytes, metadata);

      // Get the download URL
      String downloadUrl = await storageReference.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      // Handle errors
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> updateUser({
    String? firstName,
    String? lastName,
    String? address,
    String? contactNo,
    Uint8List? newPhoto,
  }) async {
    try {
      // Update user information in Firestore
      await userCollection.doc(uid).update({
        'firstname': firstName,
        'lastname': lastName,
        'address': address,
        'contactNo': contactNo
      });

      // Update user's profile photo
      if (newPhoto != null) {
        String? newPhotoUrl = await _uploadImage(newPhoto);
        await userCollection.doc(uid).update({
          'photoUrl': newPhotoUrl,
        });
      }
    } catch (e) {
      // Handle errors
      print('Error updating user: $e');
      rethrow; // Rethrow the exception for higher-level handling
    }
  }

  Future<void> editUser({
    required String firstName,
    required String lastName,
    String? middleName,
    required String address,
    required String contactNo,
    Uint8List? newPhoto,
  }) async {
    try {
      // Update user information in Firestore
      await userCollection.doc(uid).update({
        'firstname': firstName,
        'middlename': middleName,
        'lastname': lastName,
        'address': address,
        'contactNo': contactNo,
      });

      // Update user's profile photo if a new photo is provided
      if (newPhoto != null) {
        String? newPhotoUrl = await _uploadImage(newPhoto);
        await userCollection.doc(uid).update({
          'photoUrl': newPhotoUrl,
        });
      }
    } catch (e) {
      // Handle errors
      print('Error editing user: $e');
      rethrow; // Rethrow the exception for higher-level handling
    }
  }

  Future<List<UserModel>> getAllUserByRole(String role) async {
    try {
      QuerySnapshot querySnapshot =
          await userCollection.where('role', isEqualTo: role).get();

      List<UserModel> users = querySnapshot.docs.map((doc) {
        Map<String, dynamic> userData =
            doc.data() as Map<String, dynamic>; // Update as per your structure
        return UserModel(
          email: userData['email'] ?? '',
          uid: doc.id,
          firstName: userData['firstname'] ?? '',
          middleName: userData['middlename'] ?? '',
          lastName: userData['lastname'] ?? '',
          address: userData['address'] ?? '',
          role: userData['role'] ?? '',
          photoUrl: userData['photoUrl'] ?? '',
          contactNo: userData['contactNo'],
        );
      }).toList();

      return users;
    } catch (e) {
      print('Error getting users by role: $e');
      throw e;
    }
  }

  Future<List<UserModel>> getAllUserByRoleWithMessages(String role) async {
    try {
      QuerySnapshot querySnapshot =
          await userCollection.where('role', isEqualTo: role).get();

      List<UserModel> users = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> userData =
            doc.data() as Map<String, dynamic>; // Update as per your structure

        // Check if the user has messages
        bool hasMessages = await chatService.hasMessages(doc.id);

        if (hasMessages) {
          UserModel user = UserModel(
            email: userData['email'] ?? '',
            uid: doc.id,
            firstName: userData['firstname'] ?? '',
            middleName: userData['middlename'] ?? '',
            lastName: userData['lastname'] ?? '',
            address: userData['address'] ?? '',
            role: userData['role'] ?? '',
            photoUrl: userData['photoUrl'] ?? '',
            contactNo: userData['contactNo'],
          );

          users.add(user);
        }
      }

      return users;
    } catch (e) {
      print('Error getting users by role: $e');
      throw e;
    }
  }
}
