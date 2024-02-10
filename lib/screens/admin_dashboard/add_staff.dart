import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/services/auth_service.dart';

class AddStaffWidget extends StatefulWidget {
  const AddStaffWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddStaffWidgetState createState() => _AddStaffWidgetState();
}

class _AddStaffWidgetState extends State<AddStaffWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isloading = false;

  void _addStaff() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      try {
        await _authService.addStaff(
          _emailController.text,
          _passwordController.text,
          _firstnameController.text,
          null,
          _lastnameController.text,
          _addressController.text,
          _contactNoController.text,
        );
        setState(() {
          isloading = false;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error adding doctor: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Staff'),
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
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
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
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastnameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactNoController,
                decoration: const InputDecoration(labelText: 'Contact No.'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              isloading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addStaff,
                      child: const Text('Add Staff'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
