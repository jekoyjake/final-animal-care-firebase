import 'package:animalcare/models/appointment.dart';
import 'package:animalcare/models/pet.dart';
import 'package:animalcare/models/user.dart';
import 'package:animalcare/services/appointment_service.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/notif.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class AppointmentDash extends StatefulWidget {
  const AppointmentDash({super.key});

  @override
  State<AppointmentDash> createState() => _AppointmentDashState();
}

class _AppointmentDashState extends State<AppointmentDash> {
  DateTime? selectedDate;
  bool hasError = false;
  bool isLoading = false;
  String? petId;
  String? sucmsg;
  String? errmsg;
  bool subHasErr = false;
  DateTime _selectedDate = DateTime.now();
  String msg = "Please select 8:00 AM to 5:00 PM only";
  DateTime getNextSelectableWeekday(DateTime date) {
    // Skip weekends (Saturday and Sunday) to find the next selectable weekday
    while (
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final AppointmentService appointmentService = AppointmentService();
    final UserService userService = UserService(uid: _authService.uid!);

    return Scaffold(
      body: Center(
        child: Container(
          height: 650,
          width: 750,
          decoration: const BoxDecoration(color: Color(0xFF6665FE)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create an Appointment",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  Theme(
                    data: ThemeData.dark(),
                    child: FormBuilderDateTimePicker(
                      name: 'date_and_time',
                      inputType: InputType.both,
                      format: DateFormat('yyyy-MM-dd HH:mm:ss'),
                      decoration: const InputDecoration(
                        labelText: 'Click here to select time and date',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        prefixIcon:
                            Icon(Icons.calendar_today, color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
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
                              selectedDate = newDate;
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
                        style: TextStyle(color: Colors.white70),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70, // Customize the icon color
                      ),
                      const SizedBox(height: 20),
                      Text(
                        selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                            : 'No date selected',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "Selected Time:",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const Icon(
                        Icons.watch,
                        color: Colors.white70, // Customize the icon color
                      ),
                      Text(
                        selectedDate != null
                            ? DateFormat('hh:mm:ss a').format(selectedDate!)
                            : 'No time selected',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                  if (hasError)
                    Text(
                      msg,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  FutureBuilder<List<PetModel>>(
                    future: PetService(uid: _authService.uid!).getPetsForUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Nothing to select');
                      } else {
                        List<PetModel> pets = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButton<String>(
                              value: petId,
                              onChanged: (String? newValue) {
                                setState(() {
                                  petId = newValue!;
                                });
                              },
                              items: pets.map((pet) {
                                return DropdownMenuItem(
                                  value: pet.id,
                                  child: Text(
                                    pet.name,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            petId != null
                                ? Row(children: [
                                    Image.network(
                                      pets
                                          .firstWhere((pet) => pet.id == petId)
                                          .photoUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pet ID:    $petId',
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Pet Name:    ${pets.firstWhere((pet) => pet.id == petId).name}',
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Pet Species:    ${pets.firstWhere((pet) => pet.id == petId).species}',
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ])
                                : const Text(
                                    "No pets selected",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                            const SizedBox(
                              height: 15,
                            ),
                            isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      NotificationService _noftifservice =
                                          NotificationService();
                                      var res = await appointmentService
                                          .addAppointment(
                                              selectedDate!, petId!);
                                      if (res ==
                                          "Appointment successfully added") {
                                        setState(() {
                                          sucmsg = res;
                                        });
                                        var user = await userService
                                            .getUserDetailById();
                                        var msg =
                                            "You have recieve appointment request from ${await userService.getUserDetailById()}";
                                        await _noftifservice
                                            .addAppointmentNotification(
                                                _authService.uid!,
                                                "userId",
                                                msg);
                                        // Clear form fields
                                        petId = null;
                                        selectedDate = null;
                                        hasError = false;

                                        // Reset state variables
                                        setState(() {
                                          _selectedDate = DateTime.now();
                                        });

                                        // Navigate back to the previous screen
                                      } else {
                                        setState(() {
                                          hasError = true;
                                          errmsg = res;
                                        });
                                      }
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: Text('Submit'),
                                  ),
                            hasError ? Text(errmsg ?? "") : Text(sucmsg ?? "")
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
      ),
    );
  }
}
