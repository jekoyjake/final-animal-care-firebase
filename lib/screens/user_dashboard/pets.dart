import 'package:animalcare/models/message.dart';
import 'package:animalcare/models/notification.dart';
import 'package:animalcare/models/prescription.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/chat_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:animalcare/services/prescription_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/models/pet.dart';
import 'package:animalcare/screens/add_pet.dart';

class PetDash extends StatelessWidget {
  final void Function(int) onItemTapped;

  PetDash({Key? key, required this.onItemTapped});

  void handleTileTap(int index) {
    onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final NotificationService notificationService = NotificationService();
    final bool isMobile = MediaQuery.of(context).size.width < 600;
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
      appBar: !isMobile
          ? AppBar(
              title: const Text("Pets"),
              centerTitle: true,
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
                            .getUnreadNotificationCount(authService.uid!),
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
                    size: 50,
                  ),
                  onPressed: () {
                    // Handle logout logic
                  },
                ),
              ],
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: (() {
                handleTileTap(5);
              }),
              child: const Text('Add Pet'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PetModel>>(
              // Replace with your actual PetService and AuthService
              // Also, replace the uid with the actual user id
              future: PetService(uid: authService.uid!).getPetsForUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Center(
                          child: Text(
                    'No Pets found',
                    style: TextStyle(fontSize: 30),
                  )));
                } else {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Adjust the number of columns here
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildPetCard(context, snapshot.data![index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetModel pet) {
    return GestureDetector(
      onTap: () {
        // Navigate to the detailed view of the pet
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PetDetailScreen(pet: pet)),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                child: Image.network(
                  pet.photoUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                Text(
                  "Name: ${pet.name}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Species: ${pet.species}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Breed: ${pet.breed}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ]),
            ),
          ],
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

class PetDetailScreen extends StatefulWidget {
  final PetModel pet;

  PetDetailScreen({Key? key, required this.pet}) : super(key: key);

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final PrescriptionService _prescriptionService = PrescriptionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.name),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Row(
            children: [
              // Left Container
              Container(
                width: MediaQuery.of(context).size.width *
                    0.4, // Adjust the width as needed
                height: MediaQuery.of(context).size.height *
                    0.8, // Adjust the height as needed
                decoration:
                    BoxDecoration(color: Colors.grey, border: Border.all()),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      widget.pet.photoUrl,
                      fit: BoxFit.cover,
                      height: 200.0,
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      "Species: ${widget.pet.species}",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      "Breed: ${widget.pet.breed}",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    // Add more details as needed
                  ],
                ),
              ),
              SizedBox(width: 30),

              // Right Container (Prescription list)
              Expanded(
                child: FutureBuilder<List<Prescription>>(
                  future: _prescriptionService
                      .getPrescriptionsForPet(widget.pet.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("No prescriptions found");
                    } else {
                      List<Prescription> prescriptions = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Doctor's Prescriptions",
                            style: TextStyle(fontSize: 30),
                          ),
                          Expanded(
                            child: ListView(
                              children: prescriptions.map((prescription) {
                                return ListTile(
                                  title: Text(
                                      "Medication: ${prescription.medicationName}"),
                                  subtitle: Text(
                                      "Dosage: ${prescription.dosage}, Frequency: ${prescription.frequency} Presciption Date: ${prescription.prescriptionDate}"),
                                  // Add more details or actions as needed
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
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

void main() {
  runApp(MaterialApp(
    home: PetDash(
      onItemTapped: (index) {
        // Handle item tapped
        print('Item $index tapped.');
      },
    ),
  ));
}
