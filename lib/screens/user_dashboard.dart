import 'package:animalcare/reusable_widget/my_drawer.dart';
import 'package:animalcare/reusable_widget/settings.dart';
import 'package:animalcare/screens/add_pet.dart';
import 'package:animalcare/screens/user_dashboard/announcement.dart';
import 'package:animalcare/screens/user_dashboard/appointment.dart';
import 'package:animalcare/screens/user_dashboard/appointment_tabs.dart';
import 'package:animalcare/screens/user_dashboard/pets.dart';
import 'package:animalcare/screens/user_dashboard/user_main.dart';
import 'package:flutter/material.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

int selected = 0;

class _UserDashboardState extends State<UserDashboard> {
  Widget _buildSelectedWidget() {
    switch (selected) {
      case 0:
        return const UserDash();
      case 1:
        return PetDash(
          onItemTapped: (index) {
            setState(() {
              selected = index;
            });
          },
        );
      case 2:
        return const AnnouncementDash();
      case 3:
        return const AppointmentTabs();
      case 4:
        return const Settings();
      case 5:
        return const AddPetScreen();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      MyDrawer(
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
