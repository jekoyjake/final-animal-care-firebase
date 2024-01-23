import 'package:animalcare/models/appointment.dart';
import 'package:animalcare/models/notification.dart';
import 'package:animalcare/screens/staff_dashboard/walk_patient.dart';

import 'package:animalcare/services/appointment_service.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/patient_service.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:flutter/material.dart';
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

  Future<void> _showConfirmationDialog(String appointmentId, String? userUid,
      String petId, DateTime appointmentDate) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final PetService petService = PetService(uid: userUid!);
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
                // Close the dialog
                Navigator.of(context).pop();

                // Call the method to change the status to 'Accepted'
                try {
                  await appointmentService.changeStatusByAppointmentId(
                      appointmentId, 'Accepted');
                  print('Appointment approved successfully');

                  await patientService.addPatient(
                      userUid!, petId, appointmentDate);
                  var msg =
                      "Staff approved your appointment for your pet  ${await petService.getPetNameByUid(petId)} by ${DateFormat('MMMM d, y \'at\' h:mm a').format(appointmentDate)}";
                  await notificationService.addAppointmentNotification(
                      authService.uid!, userUid, msg);
                } catch (e) {
                  print('Error approving appointment: $e');
                }
              },
              child: Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeclineDialog(String appointmentId, String? userUid,
      DateTime appointmentDate, String petId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final PetService petService = PetService(uid: userUid!);
        return AlertDialog(
          title: Text('Confirm Decline'),
          content: Text('Are you sure you want to decline this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();
                var msg =
                    "Staff decline your appointment for your pet with id ${await petService.getPetNameByUid(petId)} by ${DateFormat('MMMM d, y \'at\' h:mm a').format(appointmentDate)}";
                await appointmentService.deleteAppointment(appointmentId);

                await notificationService.addAppointmentNotification(
                    authService.uid!, userUid!, msg);
                try {} catch (e) {
                  print('Error declining appointment: $e');
                }
              },
              child: Text('Decline'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        icon: Icon(Icons.add),
        label: Text("Manual Add Appointment"),
        onPressed: () {
          // Navigate to ManualAppointment widget
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WalkInForm()),
          );
        },
      ),
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
                    title: Text('Notifications'),
                    onTap: () {
                      showNotifications(context);
                    },
                  ),
                ),
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
      body: StreamBuilder<List<AppointmentModel>>(
        stream: appointmentService.getAppointmentsByStatus("Pending"),
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
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No appointments found');
          } else {
            List<AppointmentModel> appointments = snapshot.data!;
            return FutureBuilder<List<DataRow>>(
              future: Future.wait(
                appointments.map((appointment) async {
                  String petName = await PetService(uid: authService.uid ?? "")
                      .getPetNameByUid(appointment.petId);
                  String clientName =
                      await UserService(uid: appointment.userUid!)
                          .getUserById();
                  return DataRow(
                    cells: [
                      DataCell(Text(clientName)),
                      DataCell(Text(petName)),
                      DataCell(Text(DateFormat('MMMM d, y \'at\' h:mm a')
                          .format(appointment.appointmentDate))),
                      DataCell(
                        appointment.status == "Pending"
                            ? Text(
                                appointment.status!,
                                style: const TextStyle(
                                  backgroundColor: Colors.orangeAccent,
                                  color: Colors.white,
                                ),
                              )
                            : appointment.status == "Accepted"
                                ? Text(
                                    appointment.status!,
                                    style: const TextStyle(
                                      backgroundColor: Colors.greenAccent,
                                      color: Colors.white,
                                    ),
                                  )
                                : appointment.status == "Declined"
                                    ? Text(
                                        appointment.status!,
                                        style: const TextStyle(
                                          backgroundColor: Colors.redAccent,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(appointment.status!),
                      ),
                      DataCell(
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _showConfirmationDialog(
                                    appointment.uid,
                                    appointment.userUid,
                                    appointment.petId,
                                    appointment.appointmentDate);
                              },
                              child: Text(
                                'Approve',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Add logic to handle the "Decline" button click
                                // For now, print a message to the console
                                _showDeclineDialog(
                                    appointment.uid,
                                    appointment.userUid,
                                    appointment.appointmentDate,
                                    appointment.petId);
                              },
                              child: Text(
                                'Decline',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
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
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No appointments found');
                } else {
                  return DataTable(
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Client Name',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Pet Name',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Appointment Date',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
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
            );
          }
        },
      ),
    );
  }
}
