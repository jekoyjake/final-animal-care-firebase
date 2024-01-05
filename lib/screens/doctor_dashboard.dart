import 'package:animalcare/reusable_widget/doctor_drawer.dart';
import 'package:animalcare/reusable_widget/settings.dart';
import 'package:animalcare/screens/doctor_dashboard/appointmentfordoc.dart';
import 'package:animalcare/screens/doctor_dashboard/list_user.dart';
import 'package:animalcare/screens/doctor_dashboard/patient.dart';
import 'package:flutter/material.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

int selected = 0;

class _DoctorDashboardState extends State<DoctorDashboard> {
  Widget _buildSelectedWidget() {
    switch (selected) {
      case 0:
        return ListOfUserConvo();
      case 1:
        return const PatientDashboardDoctor();
      case 2:
        return const AppointmentDashboardDoctor();
      case 3:
        return const Settings();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      DoctorDrawer(
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
