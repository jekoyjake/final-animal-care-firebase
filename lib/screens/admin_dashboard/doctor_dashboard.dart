import 'package:animalcare/screens/admin_dashboard/add_doctor.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/models/user.dart';
import 'package:animalcare/screens/admin_dashboard/doctor_info_widget.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/user_service.dart';

class DoctorDashboardAdmin extends StatefulWidget {
  const DoctorDashboardAdmin({super.key});

  @override
  State<DoctorDashboardAdmin> createState() => _DoctorDashboardAdminState();
}

class _DoctorDashboardAdminState extends State<DoctorDashboardAdmin> {
  final UserService userService =
      UserService(uid: 'YOUR_USER_ID'); // Replace with actual user ID
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctors"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Add doctor logic here
                // Navigate to the screen where you can add a new doctor
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddDoctorWidget(),
                  ),
                );
              },
              child: Text('Add Doctor'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: userService.getAllUserByRole('doctor'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No doctors found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildDoctorCard(snapshot.data![index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(UserModel doctor) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () {
          // Navigate to the doctor's information screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorInfoWidget(doctor: doctor),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(doctor.photoUrl ?? ''),
          radius: 25,
        ),
        title: Text('${doctor.firstname} ${doctor.lastname}'),
        subtitle: Text(doctor.role),
        // Add more doctor information here if needed
      ),
    );
  }
}
