import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class StaffAdmin extends StatefulWidget {
  const StaffAdmin({super.key});

  @override
  State<StaffAdmin> createState() => _StaffAdminState();
}

class _StaffAdminState extends State<StaffAdmin> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff"),
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
