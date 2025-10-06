import 'package:flutter/material.dart';
import 'student_login.dart';
import 'teacher_login.dart';

class ChooseOptionScreen extends StatelessWidget {
  const ChooseOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Bagian atas (setengah lingkaran + logo)
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: -230,
                  left: -50,
                  right: -50,
                  child: Container(
                    height: 432,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00BFA6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 65,
                  child: CircleAvatar(
                    radius: 110,
                    backgroundColor: const Color(0xFF00BFA6),
                    child: CircleAvatar(
                      radius: 103,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            'assets/icons/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bagian bawah
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // mulai dari atas
              children: [
                const SizedBox(height: 40), // jarak lebih besar biar turun
                const Text(
                  "Choose your option",
                  style: TextStyle(
                    fontSize: 18, // sedikit lebih besar
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E63D6),
                  ),
                ),
                const SizedBox(height: 55),

                // Tombol Student & Teacher
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildOption(
                      context,
                      icon: Icons.school,
                      label: "Student",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudentLoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 80),
                    buildOption(
                      context,
                      icon: Icons.person,
                      label: "Teacher",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TeacherLoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget tombol
  Widget buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF1E63D6),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.white,
            ), // icon lebih besar
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
