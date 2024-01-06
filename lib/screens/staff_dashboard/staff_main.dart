import 'package:animalcare/models/notification.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:flutter/material.dart';

class StaffMain extends StatefulWidget {
  const StaffMain({super.key});

  @override
  State<StaffMain> createState() => _StaffMainState();
}

class _StaffMainState extends State<StaffMain> {
  bool hasData = false;
  final AuthService _authService = AuthService();
  final NotificationService notificationService = NotificationService();
  void showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: StreamBuilder<List<NotificationModel>>(
            stream: notificationService.getMyNotifStream(_authService.uid!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Loading indicator
                return CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                // Error handling
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text("No notification found");
              }

              final List<NotificationModel> notifications = snapshot.data ?? [];

              // Your UI code here using the 'notifications' list
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final NotificationModel notification = notifications[index];
                  return ListTile(
                    title: Text(notification.notifMsg),
                    // Additional details or actions can be displayed here
                  );
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              size: 50,
            ),
            onPressed: () {
              // Handle the 'Home' button tap
            },
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.notifications,
              size: 50,
            ),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry>[
                PopupMenuItem(
                  child: ListTile(
                    title: Row(
                      children: [
                        Text("Notification "),
                        hasData ? Text("🔴") : Container()
                      ],
                    ),
                    onTap: () {
                      // Handle the 'Notifications' menu item tap
                      // For example, show a modal sheet with notifications
                      showNotifications(context);
                    },
                  ),
                ),
                // Add more menu items if needed
              ];
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              size: 50,
            ),
            onPressed: () {
              // Handle the 'Logout' button tap
              // _authService.signOut();
            },
          ),
        ],
      ),
      body: Text("This is sample"),
    );
  }
}
