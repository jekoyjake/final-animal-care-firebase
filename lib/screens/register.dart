import 'package:animalcare/screens/authenticate.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register> {
  AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  String? _firstName;
  String? _middleName;
  String? _lastName;
  String? _address;
  String? _password;
  String? _confirmPassword;
  String? _contactNo;
  String? _email;

  bool isLoading = false;

  Future<String?> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid, save form data
      _formKey.currentState!.save();

      final res = await authService.registerWithEmailAndPassword(
          _email!,
          _password!,
          _firstName!,
          _middleName!,
          _lastName!,
          _address!,
          _contactNo!);

      setState(() {
        isLoading = false;
      });

      return res;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animal Care"),
        actions: [
          authService.uid != null
              ? IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    // Call your sign-out method from AuthService
                    await authService.signOut();
                  },
                )
              : Container(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                onSaved: (value) => _firstName = value,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Middle Name'),
                onSaved: (value) => _middleName = value,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
                onSaved: (value) => _lastName = value,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) => _contactNo = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contact no'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
                onSaved: (value) => _address = value,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onSaved: (value) => _password = value,
                controller: _passwordController,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onSaved: (value) => _confirmPassword = value,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 16.0),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        _submitForm();
                        String? registrationResult = await _submitForm();
                        // Handle the registration result as needed
                        if (registrationResult != null) {
                          // If registration is successful, navigate to AuthenticationScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Authenticate()),
                          );
                        }
                      },
                      child: const Text('Register'),
                    ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
