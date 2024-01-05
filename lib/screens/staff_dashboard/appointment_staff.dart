import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class AppointmentStaff extends StatefulWidget {
  const AppointmentStaff({super.key});

  @override
  State<AppointmentStaff> createState() => _AppointmentStaffState();
}

class _AppointmentStaffState extends State<AppointmentStaff> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
            },
          ),
        ],
      ),
      body: Text("This is sample"),
    );
  }
}
