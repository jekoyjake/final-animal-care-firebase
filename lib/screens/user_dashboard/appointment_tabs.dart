import 'package:animalcare/models/message.dart';
import 'package:animalcare/models/notification.dart';
import 'package:animalcare/screens/user_dashboard/appointment.dart';
import 'package:animalcare/screens/user_dashboard/appointment_list.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/chat_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentTabs extends StatefulWidget {
  const AppointmentTabs({super.key});

  @override
  State<AppointmentTabs> createState() => _AppointmentTabsState();
}

class _AppointmentTabsState extends State<AppointmentTabs> {
  final AuthService _authService = AuthService();

  final NotificationService notificationService = NotificationService();
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          floatingActionButton: Tooltip(
            message: 'Start a conversation',
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF6665FE),
              onPressed: () {
                showChatDialog(context);
              },
              child: const Icon(
                Icons.message,
                color: Colors.white70,
              ),
            ),
          ),
          appBar: !isMobile
              ? AppBar(
                  backgroundColor: const Color(0xFF6665FE),
                  title: const Text("Appointments"),
                  centerTitle: true,
                  bottom: const TabBar(
                    labelColor: Colors
                        .white, // Set the text color for the selected (active) tab
                    unselectedLabelColor:
                        Colors.grey, // Set the text color for unselected tabs
                    tabs: [
                      Tab(text: 'List'),
                      Tab(text: 'Add Appointment'),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.home,
                        size: 50,
                      ),
                      onPressed: () {},
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications,
                            size: 50,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                        size: 50,
                      ),
                      onPressed: () {
                        _authService.signOut();
                      },
                    ),
                  ],
                )
              : AppBar(
                  title: const Center(child: Text("Appointments")),
                  bottom: const TabBar(
                    labelColor: Colors
                        .black87, // Set the text color for the selected (active) tab
                    unselectedLabelColor:
                        Colors.grey, // Set the text color for unselected tabs
                    tabs: [
                      Tab(text: 'List'),
                      Tab(text: 'Add Appointment'),
                    ],
                  ),
                ),
          body: const TabBarView(
            children: [
              // Contents of Tab 1
              AppointmentListForUser(),

              // Contents of Tab 2
              AppointmentDash(),

              // Contents of Tab 3
            ],
          ),
        ),
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

void showChatDialog(BuildContext context) {
  final TextEditingController _messageController = TextEditingController();
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  // Create a ScrollController
  ScrollController _scrollController = ScrollController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          width: 450.0,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Chat with Veterinarian',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatService.getMessagesForClient(authService.uid!),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Text('No messages found');
                    } else {
                      List<Message> messages = snapshot.data!.docs
                          .map((doc) => Message.fromMap(
                              doc.data() as Map<String, dynamic>))
                          .toList();

                      // Use the ScrollController to automatically scroll to the bottom
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          bool isCurrentUser =
                              messages[index].senderId == authService.uid;
                          String senderName =
                              isCurrentUser ? 'Me' : 'Vet Doctor';

                          return Align(
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color:
                                    isCurrentUser ? Colors.blue : Colors.grey,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$senderName:',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    messages[index].messageContent,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () async {
                  String message = _messageController.text.trim();
                  if (message.isNotEmpty) {
                    await chatService.sendMessageToDoctor(message);
                    _messageController.clear();
                    final UserService userService =
                        UserService(uid: authService.uid!);

                    bool hasOnlineDoctors =
                        await userService.hasOnlineDoctors();
                    if (!hasOnlineDoctors) {
                      try {
                        String userDetail = await userService
                            .getUserDetailById(authService.uid!);

                        if (userDetail.isNotEmpty) {
                          String msg = '''
        "Hi $userDetail, thanks for contacting us.
        We've received your message and appreciate you reaching out. 
        We are currently busy or the doctor is not online, but we will get back to you as soon as we can.
        Clinic Hours: 8AM to 4PM
        OPEN: MONDAY - FRIDAY
        CLOSED: SATURDAY & SUNDAY 
        Stay safe & God Bless! 😉 "
      ''';

                          await chatService.sendMessageToClient(
                              authService.uid!, msg);
                        } else {
                          // Handle the case where userDetail is an empty string
                          print('User details not available.');
                        }
                      } catch (e) {
                        // Handle the exception if any occurs during the process
                        print('Error: $e');
                      }
                    } else {
                      // No online doctors
                      print('There are online doctors.');
                    }
                  }
                },
                child: Text('Send'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
