import 'dart:io' show File;
import 'dart:typed_data';
import 'package:animalcare/models/user.dart';
import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
    // Fetch current user data and set initial values for text fields
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      UserModel? currentUser = await _authService.user.first;
      if (currentUser != null) {
        setState(() {
          _firstNameController.text = currentUser.firstName ?? '';
          _middleNameController.text = currentUser.middleName ?? '';
          _lastNameController.text = currentUser.lastName ?? '';
          _addressController.text = currentUser.address ?? '';
          // Set the initial imageBytes if the user has a profile photo

          if (currentUser.photoUrl != null) {
            setState(() {
              toLoadImage = currentUser.photoUrl;
            });
          }
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  String? toLoadImage;
  Uint8List? _imageBytes;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _middleNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _contactNo = TextEditingController();
  bool isLoading = false;
  final AuthService _authService = AuthService();

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

  void _updateUser() async {
    setState(() {
      isLoading = true;
    });
    String firstName = _firstNameController.text.trim();
    String middleName = _middleNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String address = _addressController.text.trim();
    String? userIDDD = _authService.uid;
    String contact = _contactNo.text.trim();
    UserService userService =
        UserService(uid: userIDDD!); // Replace with actual user ID
    await userService.editUser(
      firstName: firstName,
      lastName: lastName,
      middleName: middleName.isNotEmpty ? middleName : "",
      address: address,
      contactNo: contact,
      newPhoto: _imageBytes,
    );

    // Reset text field controllers
    _firstNameController.clear();
    _lastNameController.clear();
    _middleNameController.clear();
    _addressController.clear();
    setState(() {
      _imageBytes = null; // Clear the image bytes
    });

    // Navigate back or show success message
    // ignore: use_build_context_synchronously
    setState(() {
      isLoading = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const Wrapper(), // Replace with your target screen/widget
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Info'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateUser,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _imageBytes != null
                    ? MemoryImage(_imageBytes!)
                    : toLoadImage != null
                        ? Image.network(toLoadImage!).image
                        : const AssetImage(
                            'assets/default_image.png'), // Replace with your default image asset path
                child:
                    _imageBytes == null ? Icon(Icons.person, size: 50) : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickAndUploadImage,
                child: Text('Change Profile Picture'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _middleNameController,
                decoration: InputDecoration(labelText: 'Middle Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contactNo,
                decoration: InputDecoration(labelText: 'Contact'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: _updateUser,
                      child: const Text('Update'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
