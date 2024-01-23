import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/models/user.dart';

class DoctorInfoWidget extends StatelessWidget {
  final UserModel doctor;

  DoctorInfoWidget({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Information'),
      ),
      body: Container(
        width: 400,
        height: 600,
        decoration: BoxDecoration(border: Border.all()),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: CircleAvatar(
                radius: 100, // Adjust the radius value as needed
                child: ClipOval(
                  child: doctor.photoUrl?.isNotEmpty ?? false
                      ? Image.network(
                          doctor.photoUrl!,
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          '/default.png', // Assuming 'default.png' is in the 'assets' folder
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                ),
              )),
              SizedBox(height: 16.0),
              ListTile(
                title: Text(
                  'Name:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${doctor.firstname} ${doctor.lastname}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                title: Text(
                  'Role:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${doctor.role}',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              ListTile(
                title: Text(
                  'Contact Number:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${doctor.contactNo}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              // Add more doctor information here if needed
            ],
          ),
        ),
      ),
    );
  }
}
