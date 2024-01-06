import 'package:animalcare/screens/authenticate.dart';
import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  String? _selectedAddress; // New variable for selected address
  String? _password;
  String? _confirmPassword;
  String? _contactNo;
  String? _email;

  // List of addresses
  List<String> addresses = [
    'Alipit',
    'Bagumbayan',
    'Bubukal',
    'Calios',
    'Duhat',
    'Gatid',
    'Jasaan',
    'Labuin',
    'Malinao',
    'Oogong',
    'Pagsawitan',
    'Palasan',
    'Patimbao',
    'Pob I',
    'Pob II',
    'Pob III',
    'Pob IV',
    'Pob V',
    'Pob VI',
    'Pob VII',
    'Pob VIII',
    'San Jose',
    'San Juan',
    'San Pablo Norte',
    'San Pablo Sur',
    'Santisima Cruz',
    'Santo Angel Central',
    'Santo Angel Sur',
  ];

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
          '$_selectedAddress', // Use selected address
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
      body: Center(
        child: Container(
          height: 750,
          width: 500,
          decoration: BoxDecoration(color: Color(0xFF6665FE)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        '/logo.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
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
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
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
                      decoration: InputDecoration(
                        labelText: 'Middle Name',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      onSaved: (value) => _middleName = value,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                      onSaved: (value) => _lastName = value,
                    ),
                    const SizedBox(height: 16.0),
                    // Dropdown for selecting address
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Address',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      style: TextStyle(color: Colors.blueAccent),
                      value: _selectedAddress,
                      items: addresses.map((address) {
                        return DropdownMenuItem(
                          value: address,
                          child: Text(address),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAddress = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your address';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Contact no',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your contact number';
                        }
                        return null;
                      },
                      onSaved: (value) => _contactNo = value,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
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
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
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
                                      builder: (context) => Wrapper()),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                            ),
                            child: Text(
                              'Register',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
