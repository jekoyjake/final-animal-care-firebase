import 'package:animalcare/screens/user_dashboard/appointment.dart';
import 'package:animalcare/screens/user_dashboard/appointment_history.dart';
import 'package:animalcare/screens/user_dashboard/appointment_list.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class AppointmentTabs extends StatefulWidget {
  const AppointmentTabs({super.key});

  @override
  State<AppointmentTabs> createState() => _AppointmentTabsState();
}

class _AppointmentTabsState extends State<AppointmentTabs> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF6665FE),
            title: const Text("Appointments"),
            centerTitle: true,
            bottom: const TabBar(
              labelColor: Colors
                  .white, // Set the text color for the selected (active) tab
              unselectedLabelColor:
                  Colors.grey, // Set the text color for unselected tabs
              tabs: [
                Tab(text: 'List'),
                Tab(text: 'Add Appointment'),
                Tab(text: 'History'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.home,
                  size: 50,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  size: 50,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  size: 50,
                ),
                onPressed: () {
                  _authService.signOut();
                },
              ),
            ],
          ),
          body: const TabBarView(
            children: [
              // Contents of Tab 1
              AppointmentListForUser(),

              // Contents of Tab 2
              AppointmentDash(),

              // Contents of Tab 3
              AppointmentListHistoryForUser()
            ],
          ),
        ),
      ),
    );
  }
}
