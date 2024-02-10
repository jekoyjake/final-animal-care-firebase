import 'package:animalcare/models/appointment.dart';
import 'package:animalcare/models/notification.dart';
import 'package:animalcare/models/patient.dart';
import 'package:animalcare/models/pet.dart';
import 'package:animalcare/models/prescription.dart';
import 'package:animalcare/screens/staff_dashboard/medical_history.dart';
import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/patient_service.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:animalcare/services/prescription_service.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class PatientDashboardStaff extends StatefulWidget {
  const PatientDashboardStaff({super.key});

  @override
  State<PatientDashboardStaff> createState() => _PatientDashboardStaffState();
}

class _PatientDashboardStaffState extends State<PatientDashboardStaff> {
  final AuthService _authService = AuthService();
  final PatientService _patientService = PatientService();
  final NotificationService notificationService = NotificationService();

  String _selectedDate = '';
  bool viewLoading = false;
  String patientId = "";
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void settingState() {
    setState(() {
      viewLoading = false;
    });
  }

  Future<void> _showAppointmentDialog(PatientModel patientModel) async {
    final PrescriptionService prescriptionService = PrescriptionService();
    final PetModel? petSpecies =
        await PetService(uid: patientModel.userUid).getPet(patientModel.petUid);
    final List<Prescription> listOfPres =
        await prescriptionService.getPrescriptionsForPet(petSpecies!.id);

    String getPhotoUrl = petSpecies.photoUrl;
    String petName = petSpecies.name;
    String petBreed = petSpecies.breed;
    String petSpeciess = petSpecies.species;
    String clientName =
        await UserService(uid: patientModel.userUid).getUserById();
    // ignore: use_build_context_synchronously
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final PetService petService = PetService(uid: patientModel.userUid);
        return AlertDialog(
          title: Text('Appoinment From $clientName'),
          content: Column(children: [
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 200,
              width: 200,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10.0)),
                child: Image.network(
                  getPhotoUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Pet Name: $petName"),
            const SizedBox(
              height: 10,
            ),
            Text("Pet Breed: $petBreed"),
            const SizedBox(
              height: 10,
            ),
            Text("Pet Species: $petSpeciess"),
            const SizedBox(
              height: 10,
            ),
            Text(
                "Appointment Date: ${DateFormat('MMMM d, y \'at\' h:mm a').format(patientModel.appointmentDate)}"),
            const SizedBox(
              height: 20,
            ),
          ]),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicalHostory(
                      listOfPres: listOfPres,
                      patientModel: patientModel,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                // Elevation
              ),
              child: const Text("View Medical History"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  viewLoading = false;
                });
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    ).then((value) => settingState());
  }

  Future<String> getPetName(String userUid, String petUid) async {
    return await PetService(uid: userUid).getPetNameByUid(petUid);
  }

  List<DataRow> _buildDataRows(List<PatientModel> patients) {
    List<PatientModel> filteredAppointments =
        _filterAppointmentsByDate(patients, _selectedDate);

    return filteredAppointments.map((patient) {
      Future<String> userFuture = _authService.getUserByUid(patient.userUid);
      Future<String> petNameFuture =
          PetService(uid: patient.userUid).getPetNameByUid(patient.petUid);

      return DataRow(
        cells: [
          DataCell(
            FutureBuilder<String>(
              future: userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return Text(snapshot.data ?? 'N/A');
              },
            ),
          ),
          DataCell(
            FutureBuilder<String>(
              future: petNameFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return Text(snapshot.data ?? 'N/A');
              },
            ),
          ),
          DataCell(
            Text(DateFormat('MMMM d, y \'at\' h:mm a')
                .format(patient.appointmentDate)),
          ),
          DataCell(
            Row(
              children: [
                patientId == patient.petUid
                    ? Container()
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            viewLoading = true;
                          });
                          _showAppointmentDialog(patient);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  List<PatientModel> _filterAppointmentsByDate(
    List<PatientModel> appointments,
    String selectedDate,
  ) {
    DateTime? selectedDateTime = _parseDate(selectedDate);

    if (selectedDateTime != null) {
      return appointments.where((appointment) {
        DateTime appointmentDate = appointment.appointmentDate;
        return appointmentDate.year == selectedDateTime.year &&
            appointmentDate.month == selectedDateTime.month &&
            appointmentDate.day == selectedDateTime.day;
      }).toList();
    } else {
      return appointments;
    }
  }

  DateTime? _parseDate(String date) {
    try {
      return DateFormat('yyyy-MM-dd').parse(date);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Patients",
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
      body: viewLoading
          ? const CircularProgressIndicator()
          : SizedBox(
              height: 700,
              width: 1200,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _selectDate(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              child: const Text(
                                'FILTER BY APPOINTMENT DATE',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Text(_selectedDate.isNotEmpty
                                ? 'Selected Date: $_selectedDate'
                                : 'No date selected'),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<List<PatientModel>>(
                      stream: _patientService.getAllPatients(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No patients found');
                        } else {
                          List<PatientModel> patient = snapshot.data!;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'Owner Name',
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
                                    'Options',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ],
                              rows: _buildDataRows(patient),
                            ),
                          );
                        }
                      },
                    ),
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
                  // Clear all notifications for the user
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
            // Replace 'yourUserId' with the actual user ID
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
                // Display the list of notifications or a message
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
