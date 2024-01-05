import 'package:animalcare/screens/authenticate.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showChatDialog(context);
        },
        child: const Icon(Icons.message),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('/logo.png', width: 50, height: 50),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Text('Animal Care', style: TextStyle(fontSize: 24.0)),
            ),
            Expanded(
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Home'),
                  Tab(text: 'About Us'),
                  Tab(text: 'FAQ'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Home Tab
          HomeTab(),
          // About Us Tab
          AboutUsTab(),
          // FAQ Tab
          FaqTab(),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Row(
          children: [
            // First Row: Stack of 2 Pictures
            Expanded(
              flex: 2, // Adjust the flex value based on your layout needs
              child: Container(
                height: 700,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Image.asset(
                        '/building.png', // Make sure to use the correct path
                        width: 600,
                        height: 700,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Image.asset(
                        '/dogs.png', // Make sure to use the correct path
                        width: 600,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Second Row: Column of 2 Buttons
            Expanded(
              flex: 1, // Adjust the flex value based on your layout needs
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle button 1 click
                    },
                    child: Text('Button 1'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Authenticate screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Authenticate()),
                      );
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutUsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Row(
          children: [
            // First Row: Stack of 2 Pictures
            Expanded(
              flex: 2, // Adjust the flex value based on your layout needs
              child: Container(
                height: 700,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Image.asset(
                        '/building.png', // Make sure to use the correct path
                        width: 600,
                        height: 700,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Image.asset(
                        '/dogs.png', // Make sure to use the correct path
                        width: 600,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Second Row: Column of 2 Buttons
            Expanded(
              flex: 1, // Adjust the flex value based on your layout needs
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle button 1 click
                    },
                    child: Text('Button 1'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Handle button 2 click
                    },
                    child: Text('Button 2'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaqTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Row(
          children: [
            // First Row: Stack of 2 Pictures
            Expanded(
              flex: 2, // Adjust the flex value based on your layout needs
              child: Container(
                height: 700,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Image.asset(
                        '/building.png', // Make sure to use the correct path
                        width: 600,
                        height: 700,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Image.asset(
                        '/dogs.png', // Make sure to use the correct path
                        width: 600,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Second Row: Column of 2 Buttons
            Expanded(
              flex: 1, // Adjust the flex value based on your layout needs
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle button 1 click
                    },
                    child: Text('Button 1'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Handle button 2 click
                    },
                    child: Text('Button 2'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showChatDialog(BuildContext context) {
  final TextEditingController _messageController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          width: 450.0, // Adjust the width as needed
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Chat with Veterinarian',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 10, // Replace with the actual number of messages
                  itemBuilder: (context, index) {
                    bool isCurrentUser =
                        index % 2 == 0; // Example logic, adjust as needed
                    String senderName = isCurrentUser
                        ? 'Me'
                        : 'John Doe'; // Replace 'John Doe' with the actual name

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5.0),
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$senderName:',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              'Message $index',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              // Add your input field and send button here
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Add logic to send the message
                  print('Sending message: ${_messageController.text}');
                },
                child: Text('Send'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
