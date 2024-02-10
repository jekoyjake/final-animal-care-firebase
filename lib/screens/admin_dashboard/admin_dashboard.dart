import 'dart:math';

import 'package:animalcare/screens/wrapper.dart';
import 'package:animalcare/services/appointment_service.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:animalcare/services/user_service.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({super.key});

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  late Future<List<charts.Series<AddressCount, String>>>? chartData;
  Future<List<charts.Series<SpeciesCount, String>>>? chartDataSpecies;
  final AuthService _authService = AuthService();
  final AppointmentService _appointmentService = AppointmentService();

  int _totalUsers = 0;
  int _totalPets = 0;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    fetchTotalUsers();
    fetchTotalPets();
    _loadChartData();
    _selectedMonth = DateTime.now();
    chartData = UserService(uid: _authService.uid!).getAddressCountsChart();
  }
  ///////////////////////////////

  Future<void> fetchTotalUsers() async {
    final AuthService authService = AuthService();
    final UserService userService =
        UserService(uid: authService.uid!); // Replace with actual user ID
    int totalUsers = await userService
        .totalUserCounts(); // Assuming 'user' is the role for regular users
    setState(() {
      _totalUsers = totalUsers;
    });
  }

  Future<void> fetchTotalPets() async {
    final AuthService authService = AuthService();
    final PetService petService = PetService(uid: authService.uid!);

    // Replace with actual user ID
    int totalPetss = await petService
        .getTotalPetCount(); // Assuming 'user' is the role for regular users
    setState(() {
      _totalPets = totalPetss;
    });
  }

  Future<void> _loadChartData() async {
    setState(() {
      chartDataSpecies =
          PetService(uid: _authService.uid!).getSpeciesCountsChart();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create the series list for the LineChart

    final AuthService authService = AuthService();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Main"),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                size: 30,
              ),
              onPressed: () {
                authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Wrapper()),
                );
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Row(
                    children: [
                      Card(
                        color: Colors.white70,
                        elevation: 4,
                        margin: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Total Users',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$_totalUsers',
                                style: const TextStyle(
                                    fontSize: 35, color: Colors.black),
                              ),
                              SizedBox(
                                width: 300,
                                height: 300,
                                child: FutureBuilder(
                                  future: chartData,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else {
                                      return charts.BarChart(
                                        snapshot.data as List<
                                            charts
                                            .Series<AddressCount, String>>,
                                        animate: true,
                                        vertical: false,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Row(
                    children: [
                      Card(
                        color: Colors.white70,
                        elevation: 4,
                        margin: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const Row(
                                children: [
                                  Icon(
                                    Icons.pets,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Total Pets',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$_totalPets',
                                style: const TextStyle(
                                    fontSize: 35, color: Colors.black),
                              ),
                              SizedBox(
                                width:
                                    300, // Adjust the width according to your requirement
                                height:
                                    300, // Adjust the height according to your requirement
                                child: FutureBuilder<
                                    List<charts.Series<SpeciesCount, String>>>(
                                  future: chartDataSpecies,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return charts.BarChart(
                                        snapshot.data ??
                                            [], // Pass chart data to the BarChart
                                        animate: true,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _buildMonthSelector(),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.8, // Adjust the height as needed
                  child: FutureBuilder<Map<DateTime, int>>(
                    future: _appointmentService
                        .getAppointmentDatesChartData(_selectedMonth),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        if (snapshot.data == null || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No data available'));
                        } else {
                          return _buildChart(snapshot.data!);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _selectedMonth =
                    DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
            },
          ),
          Text(
            '${_selectedMonth.year}-${_selectedMonth.month}',
            style: TextStyle(fontSize: 20),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                _selectedMonth =
                    DateTime(_selectedMonth.year, _selectedMonth.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChart(Map<DateTime, int>? appointmentData) {
    if (appointmentData == null || appointmentData.isEmpty) {
      return Center(child: Text('No data available'));
    } else {
      // Convert the appointmentData map to a list of data points
      List<charts.Series<MapEntry<DateTime, int>, DateTime>> seriesList = [
        charts.Series<MapEntry<DateTime, int>, DateTime>(
          id: 'Appointments',
          domainFn: (entry, _) => entry.key,
          measureFn: (entry, _) => entry.value,
          data: appointmentData.entries.toList(),
        )
      ];

      return Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          height: 300, // Adjust the height of the chart container
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Appointment Chart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: charts.TimeSeriesChart(
                      seriesList,
                      animate: true,
                      // Customize the appearance of the chart
                      defaultRenderer:
                          charts.LineRendererConfig(includeArea: true),
                      domainAxis: charts.DateTimeAxisSpec(
                        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                          day: charts.TimeFormatterSpec(
                            format: 'd', // Display day of the month
                            transitionFormat:
                                'MM/dd', // Format for axis label transition
                          ),
                        ),
                      ),
                      primaryMeasureAxis: const charts.NumericAxisSpec(
                        tickProviderSpec: charts.BasicNumericTickProviderSpec(
                            zeroBound: false),
                        renderSpec: charts.GridlineRendererSpec(
                          // Add a label to the y-axis
                          labelAnchor: charts.TickLabelAnchor.before,
                          labelJustification:
                              charts.TickLabelJustification.inside,
                        ),
                        // Add a label to the y-axis
                        showAxisLine: true,
                        // Label for the y-axis
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
