import 'package:animalcare/models/walkin_patient.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/walkin.dart';
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

  void navigateToWalkinDetails(String walkinId) {
    // Implement navigation to walk-in details screen
    // You can use Navigator.push or any navigation method you prefer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Dash",
          style: TextStyle(color: Colors.white70),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              size: 50,
            ),
            onPressed: () {},
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
            return FutureBuilder<List<DataRow>>(
              future: Future.wait(
                walkin.map((walkin) async {
                  // Fetch pet name using petId

                  return DataRow(
                    cells: [
                      DataCell(Text(walkin.fullname)),
                      DataCell(Text(walkin.petname)),
                      DataCell(Text(walkin.petspecies)),
                      DataCell(Text(DateFormat('MMMM d, y \'at\' h:mm a')
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
                              backgroundColor:
                                  Colors.green, // Set the button color to green
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
            );
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
