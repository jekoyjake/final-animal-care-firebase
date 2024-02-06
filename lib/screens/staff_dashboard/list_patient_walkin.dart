import 'package:animalcare/models/walkin_patient.dart';
import 'package:animalcare/screens/doctor_dashboard/add_prescription.dart';
import 'package:animalcare/screens/staff_dashboard/appointment_staff.dart';
import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:animalcare/services/walkin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalkInPatientList extends StatefulWidget {
  const WalkInPatientList({Key? key}) : super(key: key);

  @override
  State<WalkInPatientList> createState() => _WalkInPatientListState();
}

class _WalkInPatientListState extends State<WalkInPatientList> {
  final AuthService _authService = AuthService();
  final WalkinService walkinService = WalkinService();

  // Selected date for filtering
  String _selectedDate = '';

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

  Future<void> _showPatientDialog(WalkIn patient) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appoinment From ${patient.fullname}'),
          content: Column(children: [
            const SizedBox(
              height: 10,
            ),
            Text("Pet Name: ${patient.petname}"),
            const SizedBox(
              height: 10,
            ),
            Text("Pet Breed: ${patient.petbreed}"),
            const SizedBox(
              height: 10,
            ),
            Text("Pet Species: ${patient.petspecies}"),
            const SizedBox(
              height: 10,
            ),
            Text(
                "Appointment Date: ${DateFormat('MMMM d, y \'at\' h:mm a').format(patient.appointmentDate)}"),
          ]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  List<DataRow> _buildDataRows(List<WalkIn> patients) {
    List<WalkIn> filteredAppointments =
        _filterAppointmentsByDate(patients, _selectedDate);

    return filteredAppointments.map((patient) {
      return DataRow(
        cells: [
          DataCell(
            FutureBuilder<WalkIn?>(
              future: walkinService.getWalkInById(patient.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                // Use the fetched walk-in data as needed
                WalkIn? walkInData = snapshot.data;
                String ownerName = walkInData?.fullname ?? 'N/A';

                return Text(ownerName);
              },
            ),
          ),
          DataCell(
            FutureBuilder<WalkIn?>(
              future: walkinService.getWalkInById(patient.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                // Use the fetched walk-in data as needed
                WalkIn? walkInData = snapshot.data;
                String petName = walkInData?.petname ?? 'N/A';

                return Text(petName);
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
                ElevatedButton(
                  onPressed: () async {
                    _showPatientDialog(patient);
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

  List<WalkIn> _filterAppointmentsByDate(
    List<WalkIn> appointments,
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
      print('Error parsing date: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = NotificationService();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Walkin Patient",
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
      body: Container(
        height: 700,
        width: 1200,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .redAccent, // Change this color to your desired background color
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
              StreamBuilder<List<WalkIn>>(
                stream: walkinService.getAllWalk(),
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
                    List<WalkIn> patient = snapshot.data!;

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
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
