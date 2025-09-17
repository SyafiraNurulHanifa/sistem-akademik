import 'package:flutter/material.dart';
import 'student_login_screen.dart';
import 'teacher_login_screen.dart';

class ChooseOptionScreen extends StatelessWidget {
  const ChooseOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Option")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentLoginScreen()),
                );
              },
              child: const Text("Login as Student"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeacherLoginScreen()),
                );
              },
              child: const Text("Login as Teacher"),
            ),
          ],
        ),
      ),
    );
  }
}
