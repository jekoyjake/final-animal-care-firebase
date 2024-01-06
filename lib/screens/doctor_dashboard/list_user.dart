import 'package:animalcare/models/user.dart';
import 'package:animalcare/screens/doctor_dashboard/chatscreen.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/chat_service.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:flutter/material.dart';

class ListOfUserConvo extends StatelessWidget {
  // Provide the role for which you want to fetch users

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages from users'),
      ),
      body: FutureBuilder<List<UserModel>>(
        // Replace 'userUid' with the actual user id
        future: UserService(uid: authService.uid!)
            .getAllUserByRoleWithMessages("user"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildUserCard(context, snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    final ChatService chatService = ChatService();

    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8.0),
      child: Stack(
        children: [
          ListTile(
            onTap: () {
              // Handle user selection, e.g., navigate to user details screen
              _navigateToUserDetails(context, user);
            },
            leading: CircleAvatar(
              // You can use the user's photo here if available
              backgroundColor: Colors.blue,
              child: Image.network(
                user.photoUrl ?? '',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            title: Text('${user.firstName} ${user.lastName}'),
            subtitle: Text(user.address),
          ),
          Positioned(
            top: 8.0,
            right: 8.0,
            child: StreamBuilder<int>(
              stream: chatService.streamUnseenMessagesCount(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  int unseenMessageCount = snapshot.data ?? 0;

                  return Container(
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      '$unseenMessageCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUserDetails(BuildContext context, UserModel user) {
    var fullname = "${user.firstName} ${user.lastName}";
    // Implement the navigation logic to the user details screen
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatConversation(
                  otherUserId: user.uid,
                  fullname: fullname,
                )));
  }
}

void main() {
  runApp(MaterialApp(
    home: ListOfUserConvo(), // Provide the desired role
  ));
}
