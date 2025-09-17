import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // import splash

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // biar gak ada tulisan "debug"
      title: 'My App',
      theme: ThemeData(
        fontFamily: 'Poppins', // pake font Poppins dari pubspec.yaml
        primarySwatch: Colors.blue, // warna utama
      ),
      home: const SplashScreen(), // halaman pertama = splash
    );
  }
}
