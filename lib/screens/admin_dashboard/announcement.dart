import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class AnnouncementAdmin extends StatefulWidget {
  const AnnouncementAdmin({super.key});

  @override
  State<AnnouncementAdmin> createState() => _AnnouncementAdminState();
}

class _AnnouncementAdminState extends State<AnnouncementAdmin> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
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
