import 'package:animalcare/models/user.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';

class StaffDrawer extends StatefulWidget {
  final void Function(int) onItemTapped;

  const StaffDrawer({Key? key, required this.onItemTapped}) : super(key: key);

  @override
  State<StaffDrawer> createState() => _StaffDrawerState();
}

class _StaffDrawerState extends State<StaffDrawer> {
  void handleTileTap(int index) {
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return isMobile
        ? SizedBox(
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
                      height: 30, // Adjust the height to your desired size
                      width: 30, // Adjust the width to your desired size
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
                          currentAccountPicture:
                              user!.photoUrl?.isNotEmpty ?? false
                                  ? Image.network(
                                      user.photoUrl!,
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/default.png',
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.cover,
                                    ),
                          accountEmail: null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        title: const Icon(
                          Icons.calendar_month,
                          size: 50,
                        ),

                        onTap: () => handleTileTap(
                            0), // Pass index 0 when Profile is tapped
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        title: const Icon(
                          Icons.person,
                          size: 50,
                        ),

                        onTap: () => handleTileTap(
                            1), // Pass index 0 when Profile is tapped
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        title: const Icon(
                          Icons.calendar_view_day_sharp,
                          size: 50,
                        ),

                        onTap: () => handleTileTap(
                            2), // Pass index 0 when Profile is tapped
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        title: const Icon(
                          Icons.settings,
                          size: 50,
                        ),

                        onTap: () => handleTileTap(
                            3), // Pass index 0 when Profile is tapped
                      ),
                      const SizedBox(height: 40),
                      const Divider(
                        height: 10,
                        color: Colors.white,
                      ),
                      Image.asset(
                        "assets/lagunalogo.png",
                        width: 113,
                        height: 113,
                      )
                    ],
                  );
                },
              ),
            ),
          )
        : Drawer(
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
                        accountName:
                            Text("${user?.firstname} ${user?.lastname}"),
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
                        accountEmail: Text("${user?.email}"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text("Appointments"),
                      onTap: () => handleTileTap(
                          0), // Pass index 0 when Profile is tapped
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text("List of Patients"),
                      onTap: () => handleTileTap(
                          1), // Pass index 0 when Profile is tapped
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text("List of Walkin Patients"),
                      onTap: () => handleTileTap(
                          2), // Pass index 0 when Profile is tapped
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text("Settings"),
                      onTap: () => handleTileTap(
                          3), // Pass index 0 when Profile is tapped
                    ),
                    const SizedBox(height: 40),
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
          );
  }
}
