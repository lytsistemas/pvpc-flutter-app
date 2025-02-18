import 'package:flutter/material.dart';
import 'my_home_page.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this line
import 'firebase_options.dart'; // Add this line

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Add this block
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'L&T Sistemas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 17, 39, 23),
        ),
      ),
      home: const MyHomePage(title: 'Calculadora PVPC 2.0TD'),
    );
  }
}
