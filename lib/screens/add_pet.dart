import 'dart:io';
import 'dart:typed_data';
import 'package:animalcare/models/walkin_patient.dart';
import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({Key? key}) : super(key: key);

  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  AuthService _authService = AuthService();
  Uint8List? _imageBytes;

  // List of species options
  final List<String> speciesOptions = ['Cat', 'Dog', 'Others'];

  // Variable to store the selected species
  String? selectedSpecies;
  String sucmsg = "";
  bool isLoading = false;
  bool isOthers = false;
  bool isWeb = kIsWeb;
  String errM = "";

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // If form is valid, proceed with adding the pet
      String name = _nameController.text.trim();
      String species = selectedSpecies!;
      int age = int.parse(_ageController.text.trim());
      String breed = _breedController.text.trim();

      // Call your service to add the pet here
      // For example: PetService().addPet(name, species, age, breed, _imageBytes);

      // Then navigate back to the previous screen
      setState(() {
        isLoading = true;
      });

      var res = await PetService(uid: _authService.uid!).addPet(
        name: name,
        species: species,
        age: age,
        breed: breed,
        photoFile: _imageBytes,
      );

      setState(() {
        isLoading = false;
        sucmsg = "${res.name}  Successfully added";
      });

      _nameController.clear();
      _ageController.clear();
      _breedController.clear();
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

  Future<Uint8List?> xFileToUint8List(XFile file) async {
    try {
      Uint8List? uint8list;

      // Read file as bytes
      final List<int> fileBytes = await file.readAsBytes();

      // Convert bytes to Uint8List
      if (fileBytes.isNotEmpty) {
        uint8list = Uint8List.fromList(fileBytes);
      }

      return uint8list;
    } catch (e) {
      print('Error converting XFile to Uint8List: $e');
      return null;
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var converted = await xFileToUint8List(pickedFile);
      setState(() {
        _imageBytes = converted;
      });
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _imageBytes != null
                    ? MemoryImage(_imageBytes!)
                    : Image.asset("/default.png").image,
                child:
                    _imageBytes == null ? Icon(Icons.person, size: 50) : null,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (isWeb) {
                    await pickAndUploadImage();
                  } else {
                    await _getImage();
                  }
                },
                child: const Text('Add Image'),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pet Name"),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Species"),
                        DropdownButtonFormField<String>(
                          value: selectedSpecies,
                          onChanged: (String? value) {
                            setState(() {
                              selectedSpecies = value;
                              isOthers = value == "Others";
                            });
                          },
                          items: speciesOptions.map((String species) {
                            return DropdownMenuItem<String>(
                              value: species,
                              child: Text(species),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a species';
                            }
                            return null;
                          },
                        ),
                        isOthers
                            ? TextFormField(
                                decoration: InputDecoration(
                                  hintText: "Please specify",
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (isOthers &&
                                      (value == null || value.isEmpty)) {
                                    return 'Please specify';
                                  }
                                  setState(() {
                                    selectedSpecies = value;
                                  });
                                  return null;
                                },
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Age"),
                        TextFormField(
                          controller: _ageController,
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
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
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Breed"),
                        TextFormField(
                          controller: _breedController,
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a breed';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              !isLoading
                  ? ElevatedButton(
                      onPressed: () {
                        if (_imageBytes == null || _imageBytes!.isEmpty) {
                          setState(() {
                            sucmsg = "";
                            errM = "Please select an image for your pet";
                          });
                        } else {
                          setState(() {
                            errM = "";
                          });
                          _submit();
                        }
                      },
                      child: const Text('Submit'),
                    )
                  : const SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator()),
              const SizedBox(
                height: 20,
              ),
              Text(
                sucmsg,
                style: const TextStyle(
                  color: Colors.green,
                ),
              ),
              Text(
                errM,
                style: const TextStyle(
                  color: Colors.red,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
