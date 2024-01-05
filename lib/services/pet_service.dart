import 'dart:io';
import 'dart:typed_data';

import 'package:animalcare/models/pet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PetService {
  final String uid;

  PetService({required this.uid});

  final CollectionReference petCollection =
      FirebaseFirestore.instance.collection('pets');

  Future<String> _uploadImage(Uint8List imageFile) async {
    try {
      // Get a reference to the location where we'll store the file in Firebase Storage
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('pet_images/${DateTime.now()}.png');

      // Upload the file to Firebase Storage
      await storageReference.putData(imageFile);

      // Get the download URL
      String downloadUrl = await storageReference.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      // Handle errors
      print('Error uploading image: $e');
      rethrow; // Rethrow the exception for higher-level handling
    }
  }

  Future<PetModel> addPet({
    required String name,
    required String species,
    required int age,
    required String breed,
    required Uint8List? photoFile,
  }) async {
    try {
      // Upload the photo and get the download URL
      String photoUrl = await _uploadImage(photoFile!);

      // Add pet to Firestore with photo URL and user's UID
      DocumentReference petDocRef = await petCollection.add({
        'name': name,
        'species': species,
        'age': age,
        'breed': breed,
        'photoUrl': photoUrl,
        'ownerUid': uid, // Include the user's UID
      });

      // Return the created PetModel
      return PetModel(
        id: petDocRef.id,
        name: name,
        species: species,
        age: age,
        breed: breed,
        photoUrl: photoUrl,
        ownerUid: uid, // Include the user's UID in the PetModel
      );
    } catch (e) {
      // Handle errors
      print('Error adding pet: $e');
      rethrow; // Rethrow the exception for higher-level handling
    }
  }

  Future<List<PetModel>> getPetsForUser() async {
    try {
      // Fetch the documents from the user's pet collection
      QuerySnapshot querySnapshot =
          await petCollection.where('ownerUid', isEqualTo: uid).get();

      // Convert the documents to PetModel objects
      List<PetModel> pets = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return PetModel(
          id: doc.id,
          name: data['name'] ?? '',
          species: data['species'] ?? '',
          age: data['age'] ?? 0,
          breed: data['breed'] ?? '',
          photoUrl: data['photoUrl'] ?? '',
          ownerUid: data['ownerUid'] ?? '',
        );
      }).toList();

      return pets;
    } catch (e) {
      // Handle errors
      print('Error getting pets for user: $e');
      rethrow; // Rethrow the exception for higher-level handling
    }
  }

  Future<List<PetModel>> getPetByUid(String petUid) async {
    try {
      // Fetch the documents from the user's pet collection
      QuerySnapshot querySnapshot =
          await petCollection.where('ownerUid', isEqualTo: petUid).get();

      // Convert the documents to PetModel objects
      List<PetModel> pets = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return PetModel(
          id: doc.id,
          name: data['name'] ?? '',
          species: data['species'] ?? '',
          age: data['age'] ?? 0,
          breed: data['breed'] ?? '',
          photoUrl: data['photoUrl'] ?? '',
          ownerUid: data['ownerUid'] ?? '',
        );
      }).toList();

      return pets;
    } catch (e) {
      // Handle errors
      print('Error getting pets for user: $e');
      rethrow; // Rethrow the exception for higher-level handling
    }
  }

  Future<String> getPetNameByUid(String petUid) async {
    try {
      // Fetch the document for the specified pet UID
      DocumentSnapshot docSnapshot = await petCollection.doc(petUid).get();

      if (docSnapshot.exists) {
        // If the document exists, extract the pet name and return it
        String petName = docSnapshot.get('name') ?? '';
        return petName;
      } else {
        // If the document does not exist, return an empty string
        return '';
      }
    } catch (e) {
      // Handle errors
      print('Error getting pet name by UID: $e');
      rethrow; // Rethrow the exception for higher-level handling
    }
  }

  Future<void> editPet({
    required String petId,
    required String name,
    required String species,
    required int age,
    required String breed,
    required Uint8List? newPhotoFile,
  }) async {
    try {
      // Upload the new photo and get the download URL
      String newPhotoUrl = await _uploadImage(newPhotoFile!);

      // Update the pet data in Firestore with the new information
      await petCollection.doc(petId).update({
        'name': name,
        'species': species,
        'age': age,
        'breed': breed,
        'photoUrl': newPhotoUrl,
      });
    } catch (e) {
      // Handle errors
      print('Error editing pet: $e');
      rethrow; // Rethrow the exception for higher-level handling
    }
  }

  Future<String> removePet(String petId) async {
    try {
      // Delete the pet from Firestore
      await petCollection.doc(petId).delete();
      return "Pet Successfuly deleted";
    } catch (e) {
      // Handle errors
      return e.toString();
// Rethrow the exception for higher-level handling
    }
  }
}