import 'package:animalcare/models/message.dart';
import 'package:animalcare/models/notification.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/chat_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDash extends StatefulWidget {
  const UserDash({super.key});

  @override
  State<UserDash> createState() => _UserDashState();
}

class _UserDashState extends State<UserDash> {
  final AuthService _authService = AuthService();
  final NotificationService notificationService = NotificationService();
  bool hasData = false;
  void showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                StreamBuilder<List<NotificationModel>>(
                  stream:
                      notificationService.getMyNotifStream(_authService.uid!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("No notification found");
                    }

                    final List<NotificationModel> notifications =
                        snapshot.data ?? [];

                    return Column(
                      children: notifications.map((notification) {
                        return ListTile(
                          title: Text(notification.notifMsg),
                          // Additional details or actions can be displayed here
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: 16), // Adjust as needed
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      appBar: AppBar(
        title: const Text(
          "User Dash",
          style: TextStyle(color: Colors.white70),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              size: 50,
            ),
            onPressed: () {},
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
              _authService.signOut();
            },
          ),
        ],
      ),
      body: Text("This is sample"),
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
