import 'package:animalcare/models/prescription.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:animalcare/services/prescription_service.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/models/pet.dart';
import 'package:animalcare/screens/add_pet.dart';

class PetDash extends StatelessWidget {
  final void Function(int) onItemTapped;

  PetDash({Key? key, required this.onItemTapped});

  void handleTileTap(int index) {
    onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pets"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              size: 50,
            ),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  size: 50,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 0,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: const Text(
                    '5', // Replace this with your actual count
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              size: 50,
            ),
            onPressed: () {
              // Handle logout logic
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: (() {
                handleTileTap(5);
              }),
              child: const Text('Add Pet'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PetModel>>(
              // Replace with your actual PetService and AuthService
              // Also, replace the uid with the actual user id
              future: PetService(uid: authService.uid!).getPetsForUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No pets found.'));
                } else {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Adjust the number of columns here
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildPetCard(context, snapshot.data![index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetModel pet) {
    return GestureDetector(
      onTap: () {
        // Navigate to the detailed view of the pet
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PetDetailScreen(pet: pet)),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                child: Image.network(
                  pet.photoUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                Text(
                  "Name: ${pet.name}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Species: ${pet.species}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Breed: ${pet.breed}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class PetDetailScreen extends StatelessWidget {
  final PetModel pet;
  final PrescriptionService _prescriptionService = PrescriptionService();

  PetDetailScreen({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Row(
            children: [
              Container(
                width: 400,
                height: 650,
                decoration:
                    BoxDecoration(color: Colors.grey, border: Border.all()),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      pet.photoUrl,
                      fit: BoxFit.cover,
                      height: 200.0,
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      "Species: ${pet.species}",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      "Breed: ${pet.breed}",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    // Add more details as needed
                  ],
                ),
              ),
              SizedBox(
                width: 30,
              ),

              // Prescription list using FutureBuilder
              Expanded(
                child: FutureBuilder<List<Prescription>>(
                  future: _prescriptionService.getPrescriptionsForPet(pet.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("No prescriptions found");
                    } else {
                      List<Prescription> prescriptions = snapshot.data!;
                      return Column(
                        children: [
                          Text(
                            "Doctor's Prescriptions",
                            style: TextStyle(fontSize: 30),
                          ),
                          Column(
                            children: prescriptions.map((prescription) {
                              return ListTile(
                                title: Text(
                                    "Medication: ${prescription.medicationName}"),
                                subtitle: Text(
                                    "Dosage: ${prescription.dosage}, Frequency: ${prescription.frequency}"),
                                // Add more details or actions as needed
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PetDash(
      onItemTapped: (index) {
        // Handle item tapped
        print('Item $index tapped.');
      },
    ),
  ));
}
