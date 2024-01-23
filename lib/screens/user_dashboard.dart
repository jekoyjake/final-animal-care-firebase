import 'package:animalcare/models/notification.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/reusable_widget/my_drawer.dart';
import 'package:animalcare/reusable_widget/settings.dart';
import 'package:animalcare/screens/add_pet.dart';
import 'package:animalcare/screens/user_dashboard/announcement.dart';
import 'package:animalcare/screens/user_dashboard/appointment.dart';
import 'package:animalcare/screens/user_dashboard/appointment_tabs.dart';
import 'package:animalcare/screens/user_dashboard/pets.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

int selected = 1;

class _UserDashboardState extends State<UserDashboard> {
  Widget _buildSelectedWidget() {
    switch (selected) {
      case 1:
        return PetDash(
          onItemTapped: (index) {
            setState(() {
              selected = index;
            });
          },
        );
      case 2:
        return const AnnouncementDash();
      case 3:
        return const AppointmentTabs();
      case 4:
        return const Settings();
      case 5:
        return const AddPetScreen();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final AuthService _authService = AuthService();
    final NotificationService notificationService = NotificationService();

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text(
                "Dashboard",
                style: TextStyle(color: Colors.white70),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.home,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        size: 30,
                      ),
                      onPressed: () {
                        // Show notifications and mark them as read when the icon is tapped
                        showNotificationsModal(context);
                      },
                    ),
                    Positioned(
                      right: 0,
                      top: 5,
                      child: FutureBuilder<int>(
                        future: notificationService
                            .getUnreadNotificationCount(_authService.uid!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Display a loading indicator while fetching the count
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            // Handle error case
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // Display the retrieved count
                            final int unreadCount = snapshot.data ?? 0;

                            // Conditionally show or hide the container based on unreadCount
                            return unreadCount > 0
                                ? Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : SizedBox(); // An empty SizedBox to effectively hide the container
                          }
                        },
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    size: 30,
                  ),
                  onPressed: () {
                    _authService.signOut();
                  },
                ),
              ],
            )
          : null, // Hide the AppBar on mobile
      drawer: isMobile
          ? Drawer(
              child: MyDrawer(
                onItemTapped: (index) {
                  setState(() {
                    selected = index;
                    Navigator.pop(context); // Close the drawer after item tap
                  });
                },
              ),
            )
          : null, // Hide the Drawer on mobile

      body: Row(
        children: [
          // Display Drawer on larger screens
          if (!isMobile)
            Container(
              width: 250,
              child: MyDrawer(
                onItemTapped: (index) {
                  setState(() {
                    selected = index;
                  });
                },
              ),
            ),
          // Create a logic, when selected variable is changed, it will return a widget
          Expanded(child: _buildSelectedWidget())
        ],
      ),
    );
  }
}

Future<void> showNotificationsModal(BuildContext context) async {
  final NotificationService notificationService = NotificationService();
  final AuthService authService = AuthService();
  // Mark all notifications as read when showing the notifications
  await notificationService.markAllNotificationsAsRead(authService.uid!);

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      // Implement your notification list UI here
      // You can use ListView.builder or any other widget to display notifications
      return YourNotificationListWidget();
    },
  );
}

class YourNotificationListWidget extends StatefulWidget {
  @override
  State<YourNotificationListWidget> createState() =>
      _YourNotificationListWidgetState();
}

class _YourNotificationListWidgetState
    extends State<YourNotificationListWidget> {
  final NotificationService notificationService = NotificationService();

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Clear all notifications for the user
                  await notificationService
                      .deleteAllNotificationsByUserId(authService.uid!);

                  setState(() {});
                },
                child: const Text(
                  'Clear All Notifications',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<NotificationModel>>(
            // Replace 'yourUserId' with the actual user ID
            future:
                notificationService.getMyNotifStream(authService.uid!).first,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                // Display the list of notifications or a message
                final List<NotificationModel> notifications =
                    snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return Center(
                    child: Text('No Notifications'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(notifications[index].notifMsg),
                        // Add more details or customize the ListTile as needed
                      );
                    },
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
