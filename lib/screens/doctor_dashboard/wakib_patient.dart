import 'package:animalcare/models/notification.dart';
import 'package:animalcare/models/walkin_patient.dart';

import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/walkin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalkInPatient extends StatefulWidget {
  const WalkInPatient({Key? key}) : super(key: key);

  @override
  State<WalkInPatient> createState() => _WalkInPatientState();
}

class _WalkInPatientState extends State<WalkInPatient> {
  final AuthService _authService = AuthService();
  final WalkinService walkinService = WalkinService();
  final NotificationService notificationService = NotificationService();

  void navigateToWalkinDetails(String walkinId) {
    // Implement navigation to walk-in details screen
    // You can use Navigator.push or any navigation method you prefer
  }
  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Walk-In Patient",
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
                      .getUnreadNotificationCount(_authService.uid!),
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
              _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Wrapper()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<WalkIn>>(
        future: walkinService.getAllWalkIns(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: 50,
                width: 50,
                child: const Center(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(),
                  ),
                ));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No appointments found');
          } else {
            List<WalkIn> walkin = snapshot.data!;

            // Use Future.wait to wait for all asynchronous operations to complete
            if (isMobile(context)) {
              return FutureBuilder<List<ListTile>>(
                future: Future.wait(
                  walkin.map((walkn) async {
                    return ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: Text(walkn.fullname), // Client Name
                      subtitle: Text(
                          """Pet Species: ${walkn.petspecies} \n Appointment: ${DateFormat('MM/dd/yyyy h:mm a').format(walkn.appointmentDate)} """), // Pet Name
                      trailing: PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'Presciption',
                            child: Text('Presciption'),
                          ),
                          const PopupMenuItem(
                            value: 'Appointment',
                            child: Text('Appointment'),
                          ),
                        ],
                        onSelected: (value) {
                          // Handle the selection of the option
                          if (kDebugMode) {
                            print('Selected option: $value');
                          }
                        },
                        icon: const Icon(
                            Icons.more_vert), // Icon for the three dots
                      ),
                      tileColor:
                          Colors.transparent, // Adjust the tile color as needed
                      onTap: () {
                        // Handle item tap
                      },
                    );
                  }).toList(),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No appointments found');
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return snapshot.data?[index];
                      },
                    );
                  }
                },
              );
            } else {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: FutureBuilder<List<DataRow>>(
                      future: Future.wait(
                        walkin.map((walkin) async {
                          // Fetch pet name using petId

                          return DataRow(
                            cells: [
                              DataCell(Text(walkin.fullname)),
                              DataCell(Text(walkin.petname)),
                              DataCell(Text(walkin.petspecies)),
                              DataCell(Text(
                                  DateFormat('MMMM d, y \'at\' h:mm a')
                                      .format(walkin.appointmentDate))),
                              DataCell(
                                Row(children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Add logic to handle the "View" button click
                                      // For now, print a message to the console
                                      print(
                                          'View button clicked for walkin ${walkin.uid}');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .green, // Set the button color to green
                                    ),
                                    child: const Text(
                                      'Add prescription',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Add logic to handle the "View" button click
                                      // For now, print a message to the console
                                      print(
                                          'View button clicked for walkin ${walkin.uid}');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .orangeAccent, // Set the button color to green
                                    ),
                                    child: const Text(
                                      'Make new appointment',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ]),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                              height: 50,
                              width: 50,
                              child: const Center(
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: CircularProgressIndicator(),
                                ),
                              ));
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No appointments found');
                        } else {
                          return DataTable(
                            columns: const [
                              DataColumn(
                                  label: Text(
                                'Owner Name',
                                style: TextStyle(fontSize: 20),
                              )),
                              DataColumn(
                                  label: Text(
                                'Pet Name',
                                style: TextStyle(fontSize: 20),
                              )),
                              DataColumn(
                                  label: Text(
                                'Pet Type',
                                style: TextStyle(fontSize: 20),
                              )),
                              DataColumn(
                                label: Text(
                                  'Appointment Date',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Options',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                            rows: snapshot.data!,
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WalkInPatient(),
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
