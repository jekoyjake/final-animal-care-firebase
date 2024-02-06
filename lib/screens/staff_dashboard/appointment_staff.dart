import 'package:animalcare/models/appointment.dart';
import 'package:animalcare/models/notification.dart';
import 'package:animalcare/models/pet.dart';
import 'package:animalcare/screens/staff_dashboard/walk_patient.dart';
import 'package:animalcare/screens/wrapper.dart';

import 'package:animalcare/services/appointment_service.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/patient_service.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class AppointmentStaff extends StatefulWidget {
  const AppointmentStaff({super.key});

  @override
  State<AppointmentStaff> createState() => _AppointmentStaffState();
}

class _AppointmentStaffState extends State<AppointmentStaff> {
  final AppointmentService appointmentService = AppointmentService();
  final AuthService authService = AuthService();
  final AuthService _authService = AuthService();
  final PatientService patientService = PatientService();
  final NotificationService notificationService = NotificationService();

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
                  stream: notificationService.getNotifForAppointment(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No notification found");
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
                const SizedBox(height: 16), // Adjust as needed
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationDialog(AppointmentModel appointment) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final PetService petService = PetService(uid: appointment.userUid!);
        return AlertDialog(
          title: const Text('Confirm Approval'),
          content:
              const Text('Are you sure you want to approve this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  await appointmentService.changeStatusByAppointmentId(
                      appointment.uid, 'Accepted');
                  if (kDebugMode) {
                    print('Appointment approved successfully');
                  }

                  await patientService.addPatient(appointment.userUid!,
                      appointment.petId, appointment.appointmentDate);
                  var msg =
                      "Staff approved your appointment for your pet  ${await petService.getPetNameByUid(appointment.petId)} by ${DateFormat('MMMM d, y \'at\' h:mm a').format(appointment.appointmentDate)}";
                  await notificationService.addAppointmentNotification(
                      "userId", appointment.userUid!, msg);
                } catch (e) {
                  if (kDebugMode) {
                    print('Error approving appointment: $e');
                  }
                }
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAppointmentDialog(
    AppointmentModel appointmentModel,
  ) async {
    final PetService petService = PetService(uid: appointmentModel.userUid!);
    PetModel? petSpecies = await PetService(uid: authService.uid ?? "")
        .getPet(appointmentModel.petId);
    String clientName =
        await UserService(uid: appointmentModel.userUid!).getUserById();
    // ignore: use_build_context_synchronously
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Appointment from $clientName"),
          content:
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text("Species: ${petSpecies!.species}"),
            Text(
                "Appoinment Date: ${DateFormat('MMMM d, y \'at\' h:mm a').format(appointmentModel.appointmentDate)}")
          ]),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      // Color when button is pressed
                      return Colors.blueAccent;
                    }
                    // Default color
                    return Colors.blueGrey;
                  },
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      // Color when button is pressed
                      return Color.fromARGB(255, 145, 7, 37);
                    }
                    // Default color
                    return Colors.red;
                  },
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await appointmentService.changeStatusByAppointmentId(
                      appointmentModel.uid, 'Declined');
                  if (kDebugMode) {
                    print('Declined successfuly');
                  }

                  var msg =
                      "Staff declined your appointment for your pet  ${await petService.getPetNameByUid(appointmentModel.petId)} by ${DateFormat('MMMM d, y \'at\' h:mm a').format(appointmentModel.appointmentDate)}";
                  await notificationService.addAppointmentNotification(
                      authService.uid!, appointmentModel.userUid!, msg);
                } catch (e) {
                  if (kDebugMode) {
                    print('Error approving appointment: $e');
                  }
                }
              },
              child: const Text(
                'Decline',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      // Color when button is pressed
                      return Colors.lightGreen;
                    }
                    // Default color
                    return Colors.green;
                  },
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  await appointmentService.changeStatusByAppointmentId(
                      appointmentModel.uid, 'Accepted');
                  if (kDebugMode) {
                    print('Appointment approved successfully');
                  }

                  await patientService.addPatient(appointmentModel.userUid!,
                      appointmentModel.petId, appointmentModel.appointmentDate);
                  var msg =
                      "Staff approved your appointment for your pet  ${await petService.getPetNameByUid(appointmentModel.petId)} by ${DateFormat('MMMM d, y \'at\' h:mm a').format(appointmentModel.appointmentDate)}";
                  await notificationService.addAppointmentNotification(
                      authService.uid!, appointmentModel.userUid!, msg);
                } catch (e) {
                  if (kDebugMode) {
                    print('Error approving appointment: $e');
                  }
                }
              },
              child:
                  const Text('Approve', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeclineDialog(AppointmentModel appointment) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final PetService petService = PetService(uid: appointment.userUid!);
        return AlertDialog(
          title: const Text('Confirm Decline'),
          content:
              const Text('Are you sure you want to decline this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();
                var msg =
                    "Staff decline your appointment for your pet with id ${await petService.getPetNameByUid(appointment.petId)} by ${DateFormat('MMMM d, y \'at\' h:mm a').format(appointment.appointmentDate)}";
                await appointmentService.deleteAppointment(appointment.uid);

                await notificationService.addAppointmentNotification(
                    authService.uid!, appointment.userUid!, msg);
                try {} catch (e) {
                  if (kDebugMode) {
                    print('Error declining appointment: $e');
                  }
                }
              },
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add),
        label: const Text("Manual Add Appointment"),
        onPressed: () {
          // Navigate to ManualAppointment widget
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WalkInForm()),
          );
        },
      ),
      appBar: AppBar(
        title: const Text(
          "Appointments",
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
                  future:
                      notificationService.getUnreadNotificationCount("userId"),
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
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: !isMobile
            ? StreamBuilder<List<AppointmentModel>>(
                stream: appointmentService.getAppointmentsByStatus("Pending"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No appointments found');
                  } else {
                    List<AppointmentModel> appointments = snapshot.data!;
                    return FutureBuilder<List<ListTile>>(
                      future: Future.wait(
                        appointments.map((appointment) async {
                          PetModel? petSpecies =
                              await PetService(uid: authService.uid ?? "")
                                  .getPet(appointment.petId);
                          String clientName =
                              await UserService(uid: appointment.userUid!)
                                  .getUserById();
                          return ListTile(
                            leading: const Icon(Icons.calendar_month),
                            title: Text(clientName), // Client Name
                            subtitle: Text(
                                "Pet Species:  ${petSpecies!.species} | Appointment Date: ${DateFormat('MMMM d, y \'at\' h:mm a').format(appointment.appointmentDate)}"), // Pet Name
                            // Appointment Date
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _showConfirmationDialog(appointment);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Accept'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    _showDeclineDialog(appointment);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  child: const Text('Decline'),
                                ),
                              ],
                            ),
                            tileColor: Colors
                                .transparent, // Adjust the tile color as needed

                            onTap: () {
                              // Handle item tap
                              _showAppointmentDialog(appointment);
                              if (kDebugMode) {
                                print('Item tapped');
                              }
                            },
                          );
                        }).toList(),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 50,
                            width: 50,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
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
                  }
                },
              )
            : StreamBuilder<List<AppointmentModel>>(
                stream: appointmentService.getAppointmentsByStatus("Pending"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No appointments found');
                  } else {
                    List<AppointmentModel> appointments = snapshot.data!;
                    return FutureBuilder<List<ListTile>>(
                      future: Future.wait(
                        appointments.map((appointment) async {
                          PetModel? petSpecies =
                              await PetService(uid: authService.uid ?? "")
                                  .getPet(appointment.petId);
                          String clientName =
                              await UserService(uid: appointment.userUid!)
                                  .getUserById();
                          return ListTile(
                            leading: const Icon(Icons.calendar_month),
                            title: Text(clientName), // Client Name
                            subtitle: Text(
                                "Pet Species: ${petSpecies!.species} "), // Pet Name
                            trailing: PopupMenuButton<String>(
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'Accept',
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showConfirmationDialog(
                                                appointment);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: Text('Accept'),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'Decline',
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showDeclineDialog(appointment);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                          ),
                                          child: const Text('Decline'),
                                        ),
                                      ),
                                    ]),

                            /* Text(DateFormat(
                                    'MMMM d, y \'at\' h:mm a')
                                .format(appointment
                                    .appointmentDate)), */ // Appointment Date
                            tileColor: Colors
                                .transparent, // Adjust the tile color as needed
                            onTap: () {
                              // Handle item tap
                              _showAppointmentDialog(appointment);
                              if (kDebugMode) {
                                print('Item tapped');
                              }
                            },
                          );
                        }).toList(),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 50,
                            width: 50,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
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
                  }
                },
              ),
      ),
    );
  }
}

Future<void> showNotificationsModal(BuildContext context) async {
  final NotificationService notificationService = NotificationService();
  final AuthService authService = AuthService();

  await notificationService.markAllNotificationsAsRead("userId");

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
                      .deleteAllNotificationsByUserId("userId");

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
            future: notificationService.getMyNotifStream("userId").first,
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
