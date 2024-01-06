import 'package:animalcare/models/patient.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/patient_service.dart';
import 'package:flutter/material.dart';

class PatientDashboardDoctor extends StatefulWidget {
  const PatientDashboardDoctor({super.key});

  @override
  State<PatientDashboardDoctor> createState() => _PatientDashboardDoctorState();
}

class _PatientDashboardDoctorState extends State<PatientDashboardDoctor> {
  final AuthService _authService = AuthService();
  final PatientService _patientService = PatientService();
  void navigateToPatientDetails(BuildContext context, PatientModel patient) {
    // Navigate to the patient details screen or handle the click event as needed
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => PatientDetailsScreen(patient: patient)));
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
        body: StreamBuilder<List<PatientModel>>(
          stream: _patientService.getAllPatients(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text("No patients found");
            } else {
              List<PatientModel> patients = snapshot.data!;
              return ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  PatientModel patient = patients[index];
                  return GestureDetector(
                    onTap: () {
                      // Handle the click event, e.g., navigate to patient details
                      navigateToPatientDetails(context, patient);
                    },
                    child: Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Patient UID: ${patient.uId}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text("User UID: ${patient.userUid}"),
                            SizedBox(height: 8),
                            Text("Pet UID: ${patient.petUid}"),
                            SizedBox(height: 8),
                            Text(
                                "Appointment Date: ${patient.appointmentDate}"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ));
  }
}
