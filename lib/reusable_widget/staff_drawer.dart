import 'package:animalcare/models/user.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class StaffDrawer extends StatelessWidget {
  final void Function(int) onItemTapped;

  const StaffDrawer({Key? key, required this.onItemTapped}) : super(key: key);

  void handleTileTap(int index) {
    onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();

    return Drawer(
      backgroundColor: const Color(0xFF6665FE),
      elevation: 0,
      shape: Border.all(
        width: 0, // Set width to 0 to remove the border
        color: Colors.transparent, // Set color to transparent
      ),
      child: StreamBuilder<UserModel?>(
        stream: authService.user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 40, // Adjust the height to your desired size
              width: 40, // Adjust the width to your desired size
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ); // Show a loading indicator while waiting for data
          }
          UserModel? user = snapshot.data;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Align(
                alignment: Alignment.center,
                child: UserAccountsDrawerHeader(
                  accountName: Text("${user?.firstName} ${user?.lastName}"),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.network(
                        user?.photoUrl ?? '',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  accountEmail: Text("${user?.email}"),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text("Appointments"),
                onTap: () =>
                    handleTileTap(0), // Pass index 0 when Profile is tapped
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () =>
                    handleTileTap(1), // Pass index 0 when Profile is tapped
              ),
              const SizedBox(height: 40),
              const Divider(
                height: 10,
                color: Colors.white,
              ),
              Image.asset(
                "/lagunalogo.png",
                width: 250,
                height: 250,
              )
            ],
          );
        },
      ),
    );
  }
}
