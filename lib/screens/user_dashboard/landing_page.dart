import 'package:animalcare/screens/authenticate.dart';
import 'package:animalcare/screens/user_dashboard.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authserv = AuthService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            isMobile(context)
                ? const SizedBox(
                    child:
                        Text('Animal Care', style: TextStyle(fontSize: 20.0)),
                  )
                : const Expanded(
                    child:
                        Text('Animal Care', style: TextStyle(fontSize: 24.0)),
                  ),
            Expanded(
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Home'),
                  Tab(text: 'About Us'),
                ],
              ),
            ),
            authserv.uid != null
                ? IconButton(
                    icon: const Icon(
                      Icons.dashboard,
                      color: Color(0xFF6665FE), // Set the custom color here
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserDashboard()),
                      );
                    },
                  )
                : Container(),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.blue, Colors.white], // Adjust colors as needed
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: const [
            // Home Tab
            HomeTab(),
            // About Us Tab
            AboutUsTab(),
          ],
        ),
      ),
    );
  }
}

void _launchURL() async {
  const url =
      'https://drive.google.com/drive/folders/17HpVGR4FxXGIOt9VT7PfJpOLiM8vtdtC?usp=sharing'; // Replace with your actual link

  // Open in a new tab for web
  html.window.open(url, '_blank');
}

void _launchURLL() async {
  const url =
      'https://www.mediafire.com/file/ph39a1bl06ql56v/animal_care_1.0.0.apk/file'; // Replace with your actual link

  // Open in a new tab for web
  html.window.open(url, '_blank');
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: isMobile
          ? SizedBox(
              width: 360,
              height: 200,
              child: Column(
                children: [
                  // First Row: Stack of 2 Pictures

                  // Adjust the flex value based on your layout needs

                  Image.asset(
                    'assets/dogs.png', // Make sure to use the correct path
                    width: 350,
                    height: 100,
                    fit: BoxFit.cover,
                  ),

                  // Second Row: Column of 2 Buttons
                  Expanded(
                    flex: 1, // Adjust the flex value based on your layout needs

                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Welcome to AnimalCare Veterinary Clinic!",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                backgroundColor: Color(0xFF6665FE),
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                              """At AnimalCare, we believe in providing compassionate and comprehensive care for your beloved pets. As a trusted partner in their health and well-being, our dedicated team of experienced veterinarians and staff are committed to ensuring that every visit to our clinic is a positive and reassuring experience.
                          
                          We understand the special bond you share with your furry friends, and that's why we strive to deliver excellence in veterinary medicine. From routine check-ups to specialized treatments, our state-of-the-art facility is equipped to meet the diverse needs of your pets.
                          
                          Explore our website to learn more about our services, meet our passionate team, and discover valuable resources for pet care. Whether you're a new pet parent or have been with us for years, AnimalCare is here to support you in providing the best possible life for your cherished companions.
                          
                          Thank you for choosing AnimalCare Veterinary Clinic. We look forward to caring for your pets and being a part of their happy and healthy journey."""),
                          const SizedBox(height: 20),
                          authService.uid != null
                              ? Container()
                              : ElevatedButton.icon(
                                  onPressed: () {
                                    _launchURL();
                                  },
                                  icon: const Icon(Icons.download, size: 24),
                                  label: const Text(
                                    'Download Android App Google Drive',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                        0xFF6665FE), // Set the button color to blue
                                  ),
                                ),
                          const SizedBox(height: 20),
                          authService.uid != null
                              ? Container()
                              : ElevatedButton.icon(
                                  onPressed: () {
                                    _launchURLL();
                                  },
                                  icon: const Icon(Icons.download, size: 24),
                                  label: const Text(
                                    'Download Android App Mediafire',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                        0xFF6665FE), // Set the button color to blue
                                  ),
                                ),
                          const SizedBox(height: 20),
                          authService.uid != null
                              ? Container()
                              : ElevatedButton(
                                  onPressed: () {
                                    // Navigate to Authenticate screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const Authenticate(),
                                      ),
                                    );
                                  },
                                  child: const Text('Login'),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                // First Row: Stack of 2 Pictures
                Expanded(
                  flex: 2, // Adjust the flex value based on your layout needs
                  child: SizedBox(
                    height: 700,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Image.asset(
                            'assets/building.png', // Make sure to use the correct path
                            width: 600,
                            height: 700,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Image.asset(
                            'assets/dogs.png', // Make sure to use the correct path
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
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Welcome to AnimalCare Veterinary Clinic!",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            backgroundColor: Color(0xFF6665FE),
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                          """At AnimalCare, we believe in providing compassionate and comprehensive care for your beloved pets. As a trusted partner in their health and well-being, our dedicated team of experienced veterinarians and staff are committed to ensuring that every visit to our clinic is a positive and reassuring experience.
                    
                    We understand the special bond you share with your furry friends, and that's why we strive to deliver excellence in veterinary medicine. From routine check-ups to specialized treatments, our state-of-the-art facility is equipped to meet the diverse needs of your pets.
                    
                    Explore our website to learn more about our services,
                    
                    """),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to Authenticate screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Authenticate(),
                            ),
                          );
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class AboutUsTab extends StatelessWidget {
  const AboutUsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: isMobile
          ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png', // Make sure to use the correct path
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Image.asset(
                      'assets/lagunalogo.png', // Make sure to use the correct path
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                // First Row: Stack of 2 Pictures
                Image.asset(
                  'assets/dogs.png', // Make sure to use the correct path
                  width: 350,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                // Second Row: Column of Mission and Vision
                const Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Mission:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '"To provide compassionate and comprehensive veterinary care, promoting the well-being of pets and fostering lasting relationships with their owners. We are dedicated to delivering excellence in veterinary medicine, continuous education, and community outreach, ensuring the highest standards of health and happiness for all animals in our care."',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Vision:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "To be recognized as the premier veterinary clinic known for its unwavering commitment to exceptional care, innovation, and client satisfaction. We aspire to be a trusted partner in the health and happiness of pets, setting the standard for veterinary excellence and community engagement. Our vision is to create a world where every pet receives the best possible care, ensuring a lifetime of health, joy, and companionship.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                // First Row: Stack of 2 Pictures
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 700,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Image.asset(
                            'assets/building.png',
                            width: 600,
                            height: 700,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Image.asset(
                            'assets/dogs.png',
                            width: 600,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Second Row: Column of 2 Buttons and Mission/Vision
                const Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Mission:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "To provide compassionate and comprehensive veterinary care, promoting the well-being of pets and fostering lasting relationships with their owners. We are dedicated to delivering excellence in veterinary medicine, continuous education, and community outreach, ensuring the highest standards of health and happiness for all animals in our care.",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Vision:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "To be recognized as the premier veterinary clinic known for its unwavering commitment to exceptional care, innovation, and client satisfaction. We aspire to be a trusted partner in the health and happiness of pets, setting the standard for veterinary excellence and community engagement. Our vision is to create a world where every pet receives the best possible care, ensuring a lifetime of health, joy, and companionship.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
