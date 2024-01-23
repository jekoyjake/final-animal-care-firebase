import 'package:animalcare/models/appointment.dart';
import 'package:animalcare/services/appointment_service.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentListForUser extends StatelessWidget {
  const AppointmentListForUser({Key? key});

  @override
  Widget build(BuildContext context) {
    final AppointmentService appointmentService = AppointmentService();
    final AuthService authService = AuthService();

    return StreamBuilder<List<AppointmentModel>>(
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
                String petName = await PetService(uid: authService.uid ?? "")
                    .getPetNameByUid(appointment.petId);
                return DataRow(
                  cells: [
                    DataCell(Text(petName)),
                    DataCell(Text(DateFormat('MMMM d, y \'at\' h:mm a')
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
                                    backgroundColor: Colors.greenAccent,
                                    color: Colors.white),
                              )
                            : appointment.status == "Declined"
                                ? Text(
                                    appointment.status!,
                                    style: const TextStyle(
                                        backgroundColor: Colors.redAccent,
                                        color: Colors.white),
                                  )
                                : Text(appointment.status!)),
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
                    ));
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                  ],
                  rows: snapshot.data!,
                );
              }
            },
          );
        }
      },
    );
  }
}
