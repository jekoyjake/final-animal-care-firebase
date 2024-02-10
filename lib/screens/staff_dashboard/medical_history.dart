import 'package:animalcare/models/patient.dart';
import 'package:animalcare/models/prescription.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class MedicalHostory extends StatelessWidget {
  final List<Prescription> listOfPres;
  final PatientModel patientModel;
  const MedicalHostory(
      {super.key, required this.listOfPres, required this.patientModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List of Medical History of your pet")),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
        child: FutureBuilder<List<ListTile>>(
          future: Future.wait(
            listOfPres.map((pres) async {
              return ListTile(
                leading: const Icon(Icons.medical_information),
                title: Text("Diagnosis: ${pres.dianosis}"),
                subtitle: Text(
                    "Prescription date: ${DateFormat('MMMM d, y \'at\' h:mm a').format(patientModel.appointmentDate)}"),

                tileColor:
                    Colors.transparent, // Adjust the tile color as needed
                onTap: () {
                  // Handle item tap

                  if (kDebugMode) {
                    print('Item tapped');
                  }
                },
              );
            }).toList(),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 50,
                width: 50,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No medical history found');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return snapshot.data?[index];
                },
              );
            }
          },
        ),
      ),
    );
  }
}
