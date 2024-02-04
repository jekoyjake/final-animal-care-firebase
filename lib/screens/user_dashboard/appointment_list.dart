import 'package:animalcare/models/appointment.dart';
import 'package:animalcare/services/appointment_service.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentListForUser extends StatelessWidget {
  const AppointmentListForUser({Key? key});

  @override
  Widget build(BuildContext context) {
    final AppointmentService appointmentService = AppointmentService();
    final AuthService authService = AuthService();
    bool isWeb = kIsWeb;
    bool isMobile(BuildContext context) {
      return MediaQuery.of(context).size.width < 600;
    }

    return isMobile(context)
        ? StreamBuilder<List<AppointmentModel>>(
            stream: appointmentService.getAllMyAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No appointments found',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              } else {
                List<AppointmentModel> appointments = snapshot.data!;

                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    AppointmentModel appointment = appointments[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title:
                            Text("${appointment.status}  ${appointment.petId}"),
                        subtitle: Text(
                          "${DateFormat('MMMM d, y \'at\' h:mm a').format(appointment.appointmentDate)}",
                        ),
                        trailing: appointment.status == "Pending"
                            ? ElevatedButton(
                                onPressed: () {
                                  _showCancelConfirmationDialog(
                                      context, appointment);
                                },
                                child: Text('Cancel'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      context, appointment);
                                },
                                child: Text('Remove'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.orange),
                                ),
                              ),
                      ),
                    );
                  },
                );
              }
            },
          )
        : isWeb
            ? StreamBuilder<List<AppointmentModel>>(
                stream: appointmentService.getAllMyAppointments(),
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
                    return const Center(
                        child: Text(
                      'No appointments found',
                      style: TextStyle(fontSize: 30),
                    ));
                  } else {
                    List<AppointmentModel> appointments = snapshot.data!;

                    // Use Future.wait to wait for all asynchronous operations to complete
                    return FutureBuilder<List<DataRow>>(
                      future: Future.wait(
                        appointments.map((appointment) async {
                          // Fetch pet name using petId
                          String petName =
                              await PetService(uid: authService.uid ?? "")
                                  .getPetNameByUid(appointment.petId);
                          return DataRow(
                            cells: [
                              DataCell(Text(petName)),
                              DataCell(Text(
                                  DateFormat('MMMM d, y \'at\' h:mm a')
                                      .format(appointment.appointmentDate))),
                              DataCell(appointment.status == "Pending"
                                  ? Text(
                                      appointment.status!,
                                      style: const TextStyle(
                                          backgroundColor: Colors.orangeAccent,
                                          color: Colors.white),
                                    )
                                  : appointment.status == "Accepted"
                                      ? Text(
                                          appointment.status!,
                                          style: const TextStyle(
                                              backgroundColor:
                                                  Colors.greenAccent,
                                              color: Colors.white),
                                        )
                                      : appointment.status == "Declined"
                                          ? Text(
                                              appointment.status!,
                                              style: const TextStyle(
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  color: Colors.white),
                                            )
                                          : Text(appointment.status!)),
                              DataCell(appointment.status == "Pending"
                                  ? ElevatedButton(
                                      onPressed: () {
                                        _showCancelConfirmationDialog(
                                            context, appointment);
                                      },
                                      child: Text('Cancel'),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(
                                            context, appointment);
                                      },
                                      child: Text('Delete'),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.orange),
                                      ),
                                    )),
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
                                'Pet Name',
                                style: TextStyle(fontSize: 20),
                              )),
                              DataColumn(
                                  label: Text(
                                'Appointment Date',
                                style: TextStyle(fontSize: 20),
                              )),
                              DataColumn(
                                  label: Text(
                                'Status',
                                style: TextStyle(fontSize: 20),
                              )),
                              DataColumn(
                                  label: Text(
                                'Action',
                                style: TextStyle(fontSize: 20),
                              )),
                            ],
                            rows: snapshot.data!,
                          );
                        }
                      },
                    );
                  }
                },
              )
            : StreamBuilder<List<AppointmentModel>>(
                stream: appointmentService.getAllMyAppointments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No appointments found',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  } else {
                    List<AppointmentModel> appointments = snapshot.data!;

                    return ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        AppointmentModel appointment = appointments[index];
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                                "${appointment.status}  ${appointment.petId}"),
                            subtitle: Text(
                              "${DateFormat('MMMM d, y \'at\' h:mm a').format(appointment.appointmentDate)}",
                            ),
                            trailing: appointment.status == "Pending"
                                ? ElevatedButton(
                                    onPressed: () {
                                      _showCancelConfirmationDialog(
                                          context, appointment);
                                    },
                                    child: Text('Cancel'),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(Colors.red),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                          context, appointment);
                                    },
                                    child: Text('Remove'),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.orange),
                                    ),
                                  ),
                          ),
                        );
                      },
                    );
                  }
                },
              );
  }

  Future<void> _showCancelConfirmationDialog(
      BuildContext context, AppointmentModel appointment) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Appointment'),
          content: Text('Are you sure you want to cancel this appointment?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                _cancelAppointment(appointment);
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, AppointmentModel appointment) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Appointment'),
          content: const Text(
              'Are you sure you want to delete this appointment? all information will be gone'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                _cancelAppointment(appointment);
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    // Implement your logic to cancel the appointment, for example:
    await AppointmentService().deleteAppointment(appointment.uid);
  }
}
