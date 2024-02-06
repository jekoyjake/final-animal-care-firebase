import 'package:animalcare/reusable_widget/my_drawer.dart';
import 'package:animalcare/reusable_widget/settings.dart';
import 'package:animalcare/reusable_widget/staff_drawer.dart';
import 'package:animalcare/reusable_widget/staff_drawer_desktop.dart';
import 'package:animalcare/screens/Staff_dashboard/Staff_main.dart';
import 'package:animalcare/screens/doctor_dashboard/patient.dart';
import 'package:animalcare/screens/doctor_dashboard/wakib_patient.dart';
import 'package:animalcare/screens/staff_dashboard/appointment_staff.dart';
import 'package:animalcare/screens/staff_dashboard/list_patient_staff.dart';
import 'package:animalcare/screens/staff_dashboard/list_patient_walkin.dart';
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
        return const PatientDashboardStaff();
      case 2:
        return const WalkInPatientList();
      case 3:
        return const Settings();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Row(children: [
      isMobile
          ? StaffDrawer(
              onItemTapped: (index) {
                setState(() {
                  selected = index;
                });
              },
            )
          : StaffDrawerDesktop(
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
