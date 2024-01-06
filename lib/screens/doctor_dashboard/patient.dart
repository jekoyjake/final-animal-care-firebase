import 'package:animalcare/models/patient.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/patient_service.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientDashboardDoctor extends StatefulWidget {
  const PatientDashboardDoctor({super.key});

  @override
  State<PatientDashboardDoctor> createState() => _PatientDashboardDoctorState();
}

class _PatientDashboardDoctorState extends State<PatientDashboardDoctor> {
  final AuthService _authService = AuthService();
  final PatientService _patientService = PatientService();

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

  List<DataRow> _buildDataRows(List<PatientModel> patients) {
    List<PatientModel> filteredAppointments =
        _filterAppointmentsByDate(patients, _selectedDate);

    return filteredAppointments.map((patient) {
      return DataRow(
        cells: [
          DataCell(
            FutureBuilder<String>(
              future: _authService.getUserByUid(patient.userUid),
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
              future: PetService(uid: patient.userUid)
                  .getPetNameByUid(patient.petUid),
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
                ElevatedButton(
                  onPressed: () {
                    print(
                        'Add Prescription button clicked for walkin ${patient.uId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Add Prescription',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print(
                        'Make New Appointment button clicked for walkin ${patient.uId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: const Text(
                    'Make New Appointment',
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
      print('Error parsing date: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patients"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
            },
          ),
        ],
      ),
      body: Container(
        height: 700,
        width: 1200,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      style: ElevatedButton.styleFrom(
                        primary: Colors
                            .redAccent, // Change this color to your desired background color
                      ),
                      child: Text(
                        'FILTER BY APPOINTMENT DATE',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Text(_selectedDate.isNotEmpty
                        ? 'Selected Date: $_selectedDate'
                        : 'No date selected'),
                  ],
                ),
              ),
              StreamBuilder<List<PatientModel>>(
                stream: _patientService.getAllPatients(),
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
                    List<PatientModel> patient = snapshot.data!;

                    return DataTable(
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
