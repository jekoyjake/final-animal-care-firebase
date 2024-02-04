import 'package:animalcare/models/message.dart';
import 'package:animalcare/models/notification.dart';
import 'package:animalcare/models/prescription.dart';
import 'package:animalcare/screens/user_dashboard/landing_page.dart';
import 'package:animalcare/screens/user_dashboard/pres_detail.dart';
import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/chat_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:animalcare/services/prescription_service.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/models/pet.dart';
import 'package:animalcare/screens/add_pet.dart';

class PetDash extends StatefulWidget {
  final void Function(int) onItemTapped;

  PetDash({Key? key, required this.onItemTapped});

  @override
  State<PetDash> createState() => _PetDashState();
}

class _PetDashState extends State<PetDash> {
  void handleTileTap(int index) {
    widget.onItemTapped(index);
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
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LandingPage()),
                    );
                  },
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
                    authService.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Wrapper()),
                    );
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
                ElevatedButton(
                  onPressed: () {
                    _showRemovePetConfirmationDialog(context, pet);
                    setState(() {});
                  },
                  child: Text('Remove Pet'),
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
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.name),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left Container
                !isMobile
                    ? Container(
                        width: MediaQuery.of(context).size.width *
                            0.8, // Adjust the width as needed
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height *
                              0.6, // Set max height
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white70, border: Border.all()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ClipOval(
                              child: Image.network(
                                widget.pet.photoUrl,
                                fit: BoxFit.cover,
                                height: MediaQuery.of(context).size.height < 600
                                    ? 150.0
                                    : 400,
                                width: MediaQuery.of(context).size.height < 600
                                    ? 150.0
                                    : 400,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Species: ${widget.pet.species}",
                                  style: const TextStyle(fontSize: 25.0),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  "Breed: ${widget.pet.breed}",
                                  style: const TextStyle(fontSize: 25.0),
                                ),
                              ],
                            ),
                            const SizedBox(height: 60.0),
                            ElevatedButton(
                              onPressed: () {
                                _showRemovePetConfirmationDialog(
                                    context, widget.pet);
                              },
                              child: const Text('Remove Pet'),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height *
                              0.6, // Set max height
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          border: Border.all(),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Image.network(
                                widget.pet.photoUrl,
                                fit: BoxFit.cover,
                                height: MediaQuery.of(context).size.height < 600
                                    ? 100.0
                                    : 400,
                                width: MediaQuery.of(context).size.height < 600
                                    ? 100.0
                                    : 400,
                              ),
                            ),
                            Text(
                              "Species: ${widget.pet.species}",
                              style: const TextStyle(fontSize: 25.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              "Breed: ${widget.pet.breed}",
                              style: const TextStyle(fontSize: 25.0),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(width: 30),
                // Right Container (Prescription list)
                FutureBuilder<List<Prescription>>(
                  future: _prescriptionService
                      .getPrescriptionsForPet(widget.pet.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text("No prescriptions found",
                              style: TextStyle(fontSize: 25.0)));
                    } else {
                      List<Prescription> prescriptions = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Doctor's Prescriptions",
                            style: TextStyle(fontSize: 30),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: prescriptions.length,
                            itemBuilder: (context, index) {
                              Prescription prescription = prescriptions[index];

                              return Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                            "Prescription Date: ${prescription.prescriptionDate}",
                                            style: const TextStyle(
                                                fontSize: 23,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                          "Medication: ${prescription.medicationName} Dosage: ${prescription.dosage}, Frequency: ${prescription.frequency} Prescription Date: ${prescription.prescriptionDate}",
                                        ),
                                        // Add more details or actions as needed
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              final AuthService authService =
                                                  AuthService();
                                              final PetService _petService =
                                                  PetService(
                                                      uid: authService.uid!);
                                              // Fetch the prescription details when the button is pressed
                                              var petname = await _petService
                                                  .getPetNameByUid(
                                                      prescription.petUid);
                                              Prescription?
                                                  selectedPrescription =
                                                  await _prescriptionService
                                                      .viewPrescriptionByUid(
                                                          prescription.petUid);
                                              print(selectedPrescription);

                                              if (selectedPrescription !=
                                                  null) {
                                                // Navigate to the next widget passing the selected prescription
                                                // ignore: use_build_context_synchronously
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PrescriptionDetail(
                                                      prescription:
                                                          selectedPrescription,
                                                      petname: petname,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor:
                                                  Colors.blue, // Text color
                                            ),
                                            child: const Text('View'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showRemovePetConfirmationDialog(
    BuildContext context, PetModel pet) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${pet.name}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _deletePet(pet);
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}

Future<void> _deletePet(PetModel pet) async {
  final AuthService authService = AuthService();
  try {
    // Implement your logic to delete the pet, for example:
    await PetService(uid: authService.uid!).removePet(pet.id);
    // You may want to navigate back to the previous screen or update the UI accordingly.
  } catch (e) {
    print('Error deleting pet: $e');
    // Handle the error as needed, for example, show an error message to the user.
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
                                  const SizedBox(height: 5.0),
                                  Text(
                                    messages[index].messageContent,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
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
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
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
