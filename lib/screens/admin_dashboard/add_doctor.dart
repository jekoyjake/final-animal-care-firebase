import 'package:flutter/material.dart';
import 'package:animalcare/services/auth_service.dart';

class AddDoctorWidget extends StatefulWidget {
  @override
  _AddDoctorWidgetState createState() => _AddDoctorWidgetState();
}

class _AddDoctorWidgetState extends State<AddDoctorWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isloading = false;

  void _addDoctor() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      try {
        // Use the AuthService to register the doctor
        await _authService.addDoctor(
          _emailController.text,
          _passwordController.text,
          _firstnameController.text,
          null, // Middlename is not needed for a doctor
          _lastnameController.text,
          _addressController.text,
          _contactNoController.text,
        );
        setState(() {
          isloading = false;
        });
        // Display the result or handle it as needed
      } catch (e) {
        // Handle errors
        print('Error adding doctor: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Doctor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _firstnameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastnameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactNoController,
                decoration: InputDecoration(labelText: 'Contact No.'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the contact number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              isloading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addDoctor,
                      child: Text('Add Doctor'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
