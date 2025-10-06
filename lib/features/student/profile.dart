import 'package:flutter/material.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        backgroundColor: const Color(0xFF27C2A0),
      ),
      body: const Center(
        child: Text(
          "This is the Student Profile Page",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
