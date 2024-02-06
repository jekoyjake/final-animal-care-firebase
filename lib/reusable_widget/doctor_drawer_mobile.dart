import 'package:animalcare/models/user.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class DoctorDrawerMob extends StatelessWidget {
  final void Function(int) onItemTapped;
  const DoctorDrawerMob({super.key, required this.onItemTapped});

  void handleTileTap(int index) {
    onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();

    return SizedBox(
      width: 115,
      child: Drawer(
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
                    accountName: Text("${user?.firstname}"),
                    currentAccountPicture: CircleAvatar(
                      child: ClipOval(
                        child: user!.photoUrl?.isNotEmpty ?? false
                            ? Image.network(
                                user.photoUrl!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/default.png',
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    accountEmail: null,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Icon(
                    Icons.message,
                    size: 50,
                  ),
                  onTap: () =>
                      handleTileTap(0), // Pass index 0 when Profile is tapped
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Icon(
                    Icons.person,
                    size: 50,
                  ),
                  onTap: () =>
                      handleTileTap(1), // Pass index 0 when Profile is tapped
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Icon(
                    Icons.calendar_view_day_rounded,
                    size: 50,
                  ),
                  onTap: () =>
                      handleTileTap(2), // Pass index 1 when Pets is tapped
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Icon(
                    Icons.settings,
                    size: 50,
                  ),
                  onTap: () =>
                      handleTileTap(3), // Pass index 1 when Pets is tapped
                ),
                const SizedBox(height: 20),
                const Divider(
                  height: 10,
                  color: Colors.white,
                ),
                Image.asset(
                  "assets/lagunalogo.png",
                  width: 250,
                  height: 250,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
