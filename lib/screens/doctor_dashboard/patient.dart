import 'package:animalcare/models/notification.dart';
import 'package:animalcare/models/patient.dart';
import 'package:animalcare/screens/doctor_dashboard/add_prescription.dart';

import 'package:animalcare/screens/wrapper.dart';

import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/patient_service.dart';
import 'package:animalcare/services/pet_service.dart';

import 'package:animalcare/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
// ignore: depend_on_referenced_packages
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
  bool hasError = false;

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
  ///////////////////////////////////////////////////////////////////

  DateTime _selectedDateAppointment = DateTime.now();
  String msg = "Please select 8:00 AM to 5:00 PM only";
  DateTime getNextSelectableWeekday(DateTime date) {
    // Skip weekends (Saturday and Sunday) to find the next selectable weekday
    while (
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  Future<void> _selectDateAppointment(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateAppointment,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime date) {
        // Disable weekends (Saturday and Sunday)
        if (date.weekday == 6 || date.weekday == 7) {
          return false;
        }
        // Disable past dates
        return !date.isBefore(DateTime.now());
      },
    );

    if (pickedDate != null && pickedDate != _selectedDateAppointment) {
      setState(() {
        _selectedDateAppointment = pickedDate;
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPrescriptionWidget(
                          petUid: patient.petUid,
                        ),
                      ),
                    );
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
                  onPressed: () async {
                    _newAppointment(patient);
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
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = NotificationService();

    final AuthService authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "List of Patients",
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
                      .getUnreadNotificationCount(authService.uid!),
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
              authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Wrapper()),
              );
            },
          ),
        ],
      ),
      body: SizedBox(
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
              ),
              StreamBuilder<List<PatientModel>>(
                stream: _patientService.getAllPatients(),
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

  void _newAppointment(PatientModel patient) async {
    final AuthService authService = AuthService();
    final UserService userService = UserService(uid: authService.uid!);
    final PetService petService = PetService(uid: authService.uid!);
    String ownerName = await userService.getUserDetailsById(patient.userUid);
    String petName = await petService.getPetNameByUid(patient.petUid);
    var petSpecies = await petService.getPet(patient.petUid);
    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        builder: (BuildContext contex) {
          return AlertDialog(
            title: const Text("Create new appointment"),
            content: Column(children: [
              Text("Owner Name: $ownerName"),
              Text("Pet Name: $petName"),
              Text("Pet Species: ${petSpecies!.species}"),
              Theme(
                data: ThemeData.dark(),
                child: FormBuilderDateTimePicker(
                  name: 'date_and_time',
                  inputType: InputType.both,
                  format: DateFormat('yyyy-MM-dd HH:mm:ss'),
                  decoration: const InputDecoration(
                    labelText: 'Click here to select time and date',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: (DateTime? newDate) {
                    if (newDate != null) {
                      final time = TimeOfDay.fromDateTime(newDate);
                      const start = TimeOfDay(hour: 8, minute: 0);
                      const end = TimeOfDay(hour: 17, minute: 0);

                      final selectedMinutes = time.hour * 60 + time.minute;
                      final startMinutes = start.hour * 60 + start.minute;
                      final endMinutes = end.hour * 60 + end.minute;

                      if (selectedMinutes < startMinutes ||
                          selectedMinutes > endMinutes) {
                        setState(() {
                          hasError = true;
                        });
                      } else {
                        setState(() {
                          _selectedDateAppointment = newDate;
                          hasError = false;
                        });
                      }
                    }
                  },
                  initialDate: getNextSelectableWeekday(DateTime.now()),
                  firstDate: getNextSelectableWeekday(DateTime.now()),
                  lastDate: getNextSelectableWeekday(
                      DateTime(DateTime.now().year + 2)),
                  selectableDayPredicate: (DateTime date) {
                    return date.weekday != DateTime.saturday &&
                        date.weekday != DateTime.sunday;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    "Selected Date:",
                    style: TextStyle(color: Colors.black),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.black, // Customize the icon color
                  ),
                  const SizedBox(height: 20),
                  Text(
                    // ignore: unnecessary_null_comparison
                    _selectedDateAppointment != null
                        ? DateFormat('yyyy-MM-dd')
                            .format(_selectedDateAppointment)
                        : 'No date selected',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    "Selected Time:",
                    style: TextStyle(color: Colors.black),
                  ),
                  const Icon(
                    Icons.watch,
                    color: Colors.black, // Customize the icon color
                  ),
                  Text(
                    // ignore: unnecessary_null_comparison
                    _selectedDateAppointment != null
                        ? DateFormat('hh:mm:ss a')
                            .format(_selectedDateAppointment)
                        : 'No time selected',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              )
            ]),
          );
        });
  }
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
