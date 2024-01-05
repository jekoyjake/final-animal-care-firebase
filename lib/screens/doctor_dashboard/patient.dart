import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class PatientDashboardDoctor extends StatefulWidget {
  const PatientDashboardDoctor({super.key});

  @override
  State<PatientDashboardDoctor> createState() => _PatientDashboardDoctorState();
}

class _PatientDashboardDoctorState extends State<PatientDashboardDoctor> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patients"),
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
