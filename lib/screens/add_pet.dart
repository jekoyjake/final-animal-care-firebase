import 'dart:typed_data';

import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({Key? key}) : super(key: key);

  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final AuthService _authService = AuthService();
  Uint8List? _imageBytes;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // If form is valid, proceed with adding the pet
      final String name = _nameController.text.trim();
      final String species = _speciesController.text.trim();
      final int age = int.parse(_ageController.text.trim());
      final String breed = _breedController.text.trim();

      // Call your service to add the pet here
      // For example: PetService().addPet(name, species, age, breed, _imageBytes);

      // Then navigate back to the previous screen
      PetService(uid: _authService.uid!).addPet(
          name: name,
          species: species,
          age: age,
          breed: breed,
          photoFile: _imageBytes);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Wrapper(),
        ),
      );
    }
  }

  Future<Uint8List?> fileToUint8List(PlatformFile file) async {
    try {
      Uint8List? uint8list;
      // Read file as bytes
      final List<int> fileBytes = await file.bytes!.toList();

      // Convert bytes to Uint8List
      if (fileBytes.isNotEmpty) {
        uint8list = Uint8List.fromList(fileBytes);
      }
      return uint8list;
    } catch (e) {
      print('Error converting file to Uint8List: $e');
      return null;
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        // If the user picks an image, update the state with the new image file

        var res = result.files.first;
        var converted = await fileToUint8List(res);

        setState(() {
          _imageBytes = converted;
        });
      }
    } catch (e) {
      // If there is an error, show a snackbar with the error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pet'),
        actions: [
          IconButton(
            onPressed: _submit,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(labelText: 'Species'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a species';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Breed'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a breed';
                  }
                  return null;
                },
              ),
              CircleAvatar(
                radius: 50,
                backgroundImage: _imageBytes != null
                    ? MemoryImage(_imageBytes!)
                    : Image.asset("/default.png")
                        .image, // Replace with your default image asset path
                child:
                    _imageBytes == null ? Icon(Icons.person, size: 50) : null,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Implement logic to pick and upload image
                  await pickAndUploadImage();
                },
                child: const Text('Add Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
