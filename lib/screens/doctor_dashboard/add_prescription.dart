import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/services/prescription_service.dart';
import 'package:intl/intl.dart';

class AddPrescriptionWidget extends StatefulWidget {
  final String petUid; // Assuming you need the pet UID for adding prescriptions

  AddPrescriptionWidget({required this.petUid});

  @override
  _AddPrescriptionWidgetState createState() => _AddPrescriptionWidgetState();
}

class _AddPrescriptionWidgetState extends State<AddPrescriptionWidget> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _addingPrescription = false;
  String formattedDate =
      DateFormat('yyyy-MM-dd h:mm:ss a').format(DateTime.now());
  String msg = "Prescription added";
  bool isSuccess = false;

  void _addPrescription() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _addingPrescription = true;
        isSuccess = false;
      });
      try {
        await PrescriptionService().addPrescription(
            diagnosis: _diagnosisController.text,
            medicationName: _medicationNameController.text,
            dosage: _dosageController.text,
            frequency: _frequencyController.text,
            petUid: widget.petUid,
            doctorUid: _authService.uid!, // Replace with actual doctor UID
            prescriptionDate: formattedDate);

        setState(() {
          _addingPrescription = false;
          isSuccess = true;
        });
        // Clear all fields
        _diagnosisController.clear();
        _medicationNameController.clear();
        _dosageController.clear();
        _frequencyController.clear();

        // You may want to show a success message or navigate to another screen
      } catch (e) {
        // Handle errors
        print('Error adding prescription: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Prescription for specific pet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _diagnosisController,
                decoration: InputDecoration(labelText: 'Diagnosis'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a diagnosis';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _medicationNameController,
                decoration: InputDecoration(labelText: 'Medication Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a medication name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(labelText: 'Dosage'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a dosage';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _frequencyController,
                decoration: InputDecoration(labelText: 'Frequency'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a frequency';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              _addingPrescription
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addPrescription,
                      child: Text('Add Prescription'),
                    ),
              SizedBox(height: 16.0),
              isSuccess
                  ? Text(
                      msg,
                      style: TextStyle(color: Colors.green),
                    )
                  : Text("")
            ],
          ),
        ),
      ),
    );
  }
}
