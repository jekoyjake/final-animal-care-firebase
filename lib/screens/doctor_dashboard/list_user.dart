import 'package:animalcare/models/notification.dart';
import 'package:animalcare/models/user.dart';
import 'package:animalcare/screens/doctor_dashboard/chatscreen.dart';

import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/chat_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:flutter/material.dart';

class ListOfUserConvo extends StatelessWidget {
  // Provide the role for which you want to fetch users

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = NotificationService();

    final AuthService authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Messages from Users",
          style: TextStyle(color: Colors.white70),
        ),
        centerTitle: true,
        actions: [
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
                      .getUnreadNotificationCount(authService.uid!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final int unreadCount = snapshot.data ?? 0;

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
                          : const SizedBox();
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
              authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Wrapper()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        // Replace 'userUid' with the actual user id
        future: UserService(uid: authService.uid!)
            .getAllUserByRoleWithMessages("user"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildUserCard(context, snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    final ChatService chatService = ChatService();

    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8.0),
      child: Stack(
        children: [
          ListTile(
            onTap: () {
              // Handle user selection, e.g., navigate to user details screen
              _navigateToUserDetails(context, user);
            },
            leading: CircleAvatar(
              // You can use the user's photo here if available
              backgroundColor: Colors.blue,
              child: Image.network(
                user.photoUrl ?? '',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            title: Text('${user.firstname} ${user.lastname}'),
            subtitle: Text(user.address),
          ),
          Positioned(
            top: 8.0,
            right: 8.0,
            child: StreamBuilder<int>(
              stream: chatService.streamUnseenMessagesCount("doctor"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  int unseenMessageCount = snapshot.data ?? 0;

                  return Container(
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      '$unseenMessageCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUserDetails(BuildContext context, UserModel user) {
    var fullname = "${user.firstname} ${user.lastname}";
    // Implement the navigation logic to the user details screen
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatConversation(
                  otherUserId: user.uid,
                  fullname: fullname,
                )));
  }
}

void main() {
  runApp(MaterialApp(
    home: ListOfUserConvo(), // Provide the desired role
  ));
}

Future<void> showNotificationsModal(BuildContext context) async {
  final NotificationService notificationService = NotificationService();
  final AuthService authService = AuthService();

  await notificationService.markAllNotificationsAsRead(authService.uid!);

  // ignore: use_build_context_synchronously
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return const YourNotificationListWidget();
    },
  );
}

class YourNotificationListWidget extends StatefulWidget {
  const YourNotificationListWidget({super.key});

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
                  await notificationService
                      .deleteAllNotificationsByUserId("doctor");

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
            future: notificationService.getMyNotifStream("doctor").first,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                final List<NotificationModel> notifications =
                    snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return const Center(
                    child: Text('No Notifications'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(notifications[index].notifMsg),
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
