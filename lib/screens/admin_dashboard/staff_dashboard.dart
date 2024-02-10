import 'package:animalcare/screens/admin_dashboard/add_staff.dart';
import 'package:animalcare/screens/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/models/user.dart';
import 'package:animalcare/screens/admin_dashboard/doctor_info_widget.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/user_service.dart';

class StaffAdmin extends StatefulWidget {
  const StaffAdmin({super.key});

  @override
  State<StaffAdmin> createState() => _StaffAdminState();
}

class _StaffAdminState extends State<StaffAdmin> {
  final UserService userService =
      UserService(uid: 'YOUR_USER_ID'); // Replace with actual user ID
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Wrapper()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddStaffWidget(),
                  ),
                );
              },
              child: const Text('Add Staff'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: userService.getAllUserByRole('staff'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No staff found.'));
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
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () {
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
      ),
    );
  }
}
