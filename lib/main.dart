import 'package:animalcare/screens/wrapper.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCu3G2tT9Xas_lwuWWdqnvOx7h7BG86sGc",
            appId: "1:713302159108:web:c408a5bb60852e8c08ea51",
            storageBucket: "animalcare-a7785.appspot.com",
            messagingSenderId: "713302159108",
            projectId: "animalcare-a7785"));
  }
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animal Care',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6665FE)),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF6665FE)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Wrapper(),
      ),
    );
  }
}
