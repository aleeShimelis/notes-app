import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/notes_provider.dart';
import 'screens/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  try {
    await Firebase.initializeApp(); // Initialize Firebase
  } catch (e) {
    print("Firebase initialization failed: $e");
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => NotesProvider()..loadNotes(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}