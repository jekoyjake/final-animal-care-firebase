import 'package:animalcare/models/announcement.dart';
import 'package:animalcare/services/announcement_service.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class AnnouncementDash extends StatelessWidget {
  const AnnouncementDash({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final AnnouncementService _announcementService = AnnouncementService();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Announcements"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.home,
                size: 50,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications,
                size: 50,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.logout,
                size: 50,
              ),
              onPressed: () {
                _authService.signOut();
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Announcement>>(
          future: _announcementService.getAllAnnouncements(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text("No announcements found");
            } else {
              List<Announcement> announcements = snapshot.data!;
              return ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  Announcement announcement = announcements[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(announcement.content),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ));
  }
}
