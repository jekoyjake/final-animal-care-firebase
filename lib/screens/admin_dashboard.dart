import 'package:animalcare/reusable_widget/admin_drawer.dart';
import 'package:animalcare/screens/admin_dashboard/announcement.dart';
import 'package:animalcare/screens/admin_dashboard/doctor_dashboard.dart';
import 'package:animalcare/screens/admin_dashboard/staff_dashboard.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

int selected = 0;

class _AdminDashboardState extends State<AdminDashboard> {
  Widget _buildSelectedWidget() {
    switch (selected) {
      case 0:
        return const DoctorDashboardAdmin();
      case 1:
        return const StaffAdmin();
      case 2:
        return AnnouncementAdmin();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AdminDrawer(
        onItemTapped: (index) {
          setState(() {
            selected = index;
          });
        },
      ),
      //create a logic, when selected variable is changes, it will return a widget
      Expanded(child: _buildSelectedWidget())
    ]);
  }
}
