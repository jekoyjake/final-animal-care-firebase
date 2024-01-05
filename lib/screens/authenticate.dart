import 'package:animalcare/reusable_widget/forgotpass.dart';
import 'package:animalcare/reusable_widget/text_form_field.dart';
import 'package:animalcare/screens/register.dart';
import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  AuthService authService = AuthService();
  bool isLoading = false;
  bool hasErr = false;
  String? errMsg;
  bool isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Row(children: [
              Expanded(
                child: Stack(
                  children: [Image.asset('/login.gif')],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xFF6665FE)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              '/logo.png',
                              width: 150,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          CustomTextField(
                            label: "Email",
                            controller: email,
                            obscureText: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your email';
                              }
                              // You can add more email validation logic here if needed
                              return null;
                            },
                            textColor: Colors.black87, // Set text color
                            fillColor: Colors.white, // Set background color
                          ),
                          const SizedBox(height: 16.0),
                          CustomTextField(
                            label: "Password",
                            controller: password,
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please provide a password';
                              }
                              // You can add more email validation logic here if needed
                              return null;
                            },
                            textColor: Colors.black87, // Set text color
                            fillColor: Colors.white, // Set background color
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          ElevatedButton(
                            onPressed: isButtonDisabled
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isLoading = true;
                                        isButtonDisabled =
                                            true; // Disable the button
                                      });

                                      String eml = email.text;
                                      String pass = password.text;

                                      var res = await authService
                                          .signInWithEmailAndPassword(
                                              eml, pass);
                                      if (res != "200") {
                                        setState(() {
                                          hasErr = true;
                                          errMsg = res;
                                        });
                                      }

                                      Future.delayed(
                                        Duration(milliseconds: 50),
                                        () {
                                          email.clear();
                                          password.clear();
                                        },
                                      );

                                      setState(() {
                                        isLoading = false;
                                        isButtonDisabled =
                                            false; // Enable the button again
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Wrapper()),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Submit'),
                          ),
                          const SizedBox(height: 16.0),
                          hasErr ? Text(errMsg!) : const Text(""),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PasswordResetForm()),
                              );
                            },
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(
                                  color: Colors.white), // Set text color
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Register()),
                              );
                            },
                            child: const Text(
                              "Don't Have an account? Click here to register",
                              style: TextStyle(
                                  color: Colors.white), // Set text color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
