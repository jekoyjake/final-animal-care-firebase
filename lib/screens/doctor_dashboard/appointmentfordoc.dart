import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class AppointmentDashboardDoctor extends StatefulWidget {
  const AppointmentDashboardDoctor({super.key});

  @override
  State<AppointmentDashboardDoctor> createState() =>
      _AppointmentDashboardDoctorState();
}

class _AppointmentDashboardDoctorState
    extends State<AppointmentDashboardDoctor> {
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
