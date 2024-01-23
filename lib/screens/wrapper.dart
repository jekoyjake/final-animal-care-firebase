import 'package:animalcare/models/user.dart';
import 'package:animalcare/screens/admin_dashboard.dart';
import 'package:animalcare/screens/authenticate.dart';
import 'package:animalcare/screens/doctor_dashboard.dart';
import 'package:animalcare/screens/staff_dashboard.dart';
import 'package:animalcare/screens/user_dashboard.dart';
import 'package:animalcare/screens/user_dashboard/landing_page.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key});

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();

    void haha() async {
      var eh = await authService.user.first;
      print(eh);
    }

    return StreamBuilder<UserModel?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData) {
            final userRole = snapshot.data!.role;
            if (userRole == "user") {
              return const UserDashboard();
            } else if (userRole == "staff") {
              return const StaffDashboard();
            } else if (userRole == "admin") {
              return const AdminDashboard();
            } else if (userRole == "doctor") {
              return const DoctorDashboard();
            } else {
              return Text('Unknown role: $userRole');
            }
          } else {
            return Authenticate();
          }
        }
      },
    );
  }
}
