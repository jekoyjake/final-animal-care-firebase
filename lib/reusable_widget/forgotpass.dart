import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/services/auth_service.dart';

class PasswordResetForm extends StatefulWidget {
  const PasswordResetForm({Key? key}) : super(key: key);

  @override
  _PasswordResetFormState createState() => _PasswordResetFormState();
}

class _PasswordResetFormState extends State<PasswordResetForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  AuthService authService = AuthService();
  bool isLoading = false;
  bool hasErr = false;
  String? msg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Reset'),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: Color(0xFF6665FE)),
          width: 300,
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Reset Password",
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true, // Set filled to true
                      fillColor: Colors.white, // Set fillColor to white
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      // You can add more email validation logic here if needed
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        String email = emailController.text;

                        var res =
                            await authService.sendPasswordResetEmail(email);

                        setState(() {
                          msg = res;
                        });

                        if (res !=
                            "Please check your email for a password reset link.") {
                          setState(() {
                            hasErr = true;
                            msg = res;
                          });
                        }

                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text('Send Reset Email'),
                  ),
                  hasErr
                      ? Text(msg ?? "An unknown error occurred.")
                      : Text(msg ?? ""),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
