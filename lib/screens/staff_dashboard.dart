import 'package:animalcare/reusable_widget/my_drawer.dart';
import 'package:animalcare/reusable_widget/settings.dart';
import 'package:animalcare/reusable_widget/staff_drawer.dart';
import 'package:animalcare/screens/Staff_dashboard/Staff_main.dart';
import 'package:animalcare/screens/staff_dashboard/appointment_staff.dart';
import 'package:flutter/material.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

int selected = 0;

class _StaffDashboardState extends State<StaffDashboard> {
  Widget _buildSelectedWidget() {
    switch (selected) {
      case 0:
        return const AppointmentStaff();
      case 1:
        return const Settings();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      StaffDrawer(
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
