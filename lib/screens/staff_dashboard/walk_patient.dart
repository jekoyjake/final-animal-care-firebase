import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/walkin.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/models/walkin_patient.dart';

class WalkInForm extends StatefulWidget {
  @override
  _WalkInFormState createState() => _WalkInFormState();
}

class _WalkInFormState extends State<WalkInForm> {
  final WalkinService walkinService = WalkinService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _petnameController = TextEditingController();
  final TextEditingController _petspeciesController = TextEditingController();
  final TextEditingController _petbreedController = TextEditingController();
  final TextEditingController _petageController = TextEditingController();

  bool isLoading = false;

  DateTime _selectedDateTime = DateTime.now();

  Future<void> _selectDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      String result = await walkinService.addWalkIn(
          _fullnameController.text,
          _petageController.text,
          _petspeciesController.text,
          _petbreedController.text,
          _petageController.text,
          _selectedDateTime);

      if (result.isNotEmpty) {
        // WalkIn added successfully, you can navigate to another screen or show a success message
        setState(() {
          isLoading = false;
        });
        _formKey.currentState?.reset();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Wrapper()),
        );
      } else {
        // Handle the case where adding WalkIn failed
        print('Error adding WalkIn');
      }
    }
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _petnameController.dispose();
    _petspeciesController.dispose();
    _petbreedController.dispose();
    _petageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add WalkIn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullnameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _petnameController,
                decoration: InputDecoration(labelText: 'Pet Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter pet name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _petspeciesController,
                decoration: InputDecoration(labelText: 'Pet Species'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter pet species';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _petbreedController,
                decoration: InputDecoration(labelText: 'Pet Breed'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter pet breed';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _petageController,
                decoration: InputDecoration(labelText: 'Pet Age'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter pet age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _selectDateTime,
                child: Text('Select Appointment Date & Time'),
              ),
              SizedBox(height: 16.0),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
