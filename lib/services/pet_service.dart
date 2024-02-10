import 'dart:math';

import 'package:animalcare/models/pet.dart';
import 'package:animalcare/services/appointment_service.dart';
import 'package:animalcare/services/patient_service.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class PetService {
  final String uid;

  PetService({required this.uid});

  final CollectionReference petCollection =
      FirebaseFirestore.instance.collection('pets');

  final AppointmentService appointmentService = AppointmentService();
  final PatientService patientService = PatientService();

  Future<String> _uploadImage(Uint8List imageFile) async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('pet_images/${DateTime.now()}.png');

      await storageReference.putData(imageFile);

      String downloadUrl = await storageReference.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      rethrow;
    }
  }

  Future<String> getPetNameByUid(String petUid) async {
    try {
      DocumentSnapshot documentSnapshot = await petCollection.doc(petUid).get();

      if (documentSnapshot.exists) {
        String petName = documentSnapshot['name'];
        return petName;
      } else {
        return "Pet Name";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting pet name by UID: $e");
      }
      return e.toString();
    }
  }

  Future<PetModel?> getPet(String petId) async {
    try {
      DocumentSnapshot documentSnapshot = await petCollection.doc(petId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        // Convert the data to a PetModel object
        return PetModel(
          id: documentSnapshot.id,
          name: data['name'] ?? '',
          species: data['species'] ?? '',
          age: data['age'] ?? 0,
          breed: data['breed'] ?? '',
          photoUrl: data['photoUrl'] ?? '',
          ownerUid: data['ownerUid'] ?? '',
        );
      } else {
        return null;
      }
    } catch (e) {
      // Handle errors
      if (kDebugMode) {
        print('Error getting pet by ID: $e');
      }
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
      String photoUrl = await _uploadImage(photoFile!);

      DocumentReference petDocRef = await petCollection.add({
        'name': name,
        'species': species,
        'age': age,
        'breed': breed,
        'photoUrl': photoUrl,
        'ownerUid': uid,
      });

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
      if (kDebugMode) {
        print('Error adding pet: $e');
      }
      rethrow; // Rethrow the exception for higher-level handling
    }
  }

  Future<List<PetModel>> getPetsForUser() async {
    try {
      QuerySnapshot querySnapshot =
          await petCollection.where('ownerUid', isEqualTo: uid).get();

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
      if (kDebugMode) {
        print('Error getting pets for user: $e');
      }
      rethrow;
    }
  }

  Future<List<PetModel>> getPetByUid(String petUid) async {
    try {
      QuerySnapshot querySnapshot =
          await petCollection.where('ownerUid', isEqualTo: petUid).get();

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
      if (kDebugMode) {
        print('Error getting pets for user: $e');
      }
      rethrow;
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
      String newPhotoUrl = await _uploadImage(newPhotoFile!);

      await petCollection.doc(petId).update({
        'name': name,
        'species': species,
        'age': age,
        'breed': breed,
        'photoUrl': newPhotoUrl,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error editing pet: $e');
      }
      rethrow;
    }
  }

  Future<String?> getPetId(String petUid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('pets')
        .where('petUid', isEqualTo: petUid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return null;
    }
  }

  Future<String> removePet(String petId) async {
    try {
      await petCollection.doc(petId).delete();

      return "Pet Successfuly deleted";
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<charts.Series<SpeciesCount, String>>>
      getSpeciesCountsChart() async {
    try {
      QuerySnapshot querySnapshot = await petCollection.get();

      Map<String, int> speciesCounts = {};
      for (var doc in querySnapshot.docs) {
        String species = doc.get('species') ?? 'Unknown';
        speciesCounts.update(species, (value) => value + 1, ifAbsent: () => 1);
      }

      List<SpeciesCount> data = speciesCounts.entries.map((entry) {
        return SpeciesCount(entry.key, entry.value);
      }).toList();

      return [
        charts.Series<SpeciesCount, String>(
          id: 'Species Counts',
          domainFn: (SpeciesCount count, _) => count.species,
          measureFn: (SpeciesCount count, _) => count.count,
          data: data,
          colorFn: (_, __) =>
              _getRandomColor(), // Assign random color to each bar
          labelAccessorFn: (SpeciesCount count, _) => '${count.count}',
        )
      ];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching species counts: $e');
      }
      rethrow;
    }
  }

  // Function to generate a random color
  charts.Color _getRandomColor() {
    final random = Random();
    return charts.Color(
      r: random.nextInt(256),
      g: random.nextInt(256),
      b: random.nextInt(256),
    );
  }

  Future<int> getTotalPetCount() async {
    try {
      QuerySnapshot querySnapshot = await petCollection.get();
      if (kDebugMode) {
        print(querySnapshot.size);
      }
      return querySnapshot.size;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching total pet count: $e');
      }
      rethrow;
    }
  }
}

class SpeciesCount {
  final String species;
  final int count;

  SpeciesCount(this.species, this.count);
}
