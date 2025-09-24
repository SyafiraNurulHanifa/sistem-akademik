// choose_option_screen.dart
import 'package:flutter/material.dart';
import 'student_login_screen.dart';
import 'teacher_login_screen.dart';
import '../../admin/admin_login_page.dart';

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
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 50),
          const Text(
            "Pilih Peran Anda",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E63D6),
            ),
          ),
          const SizedBox(height: 30),

          // Tombol pilihan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 20,
                runSpacing: 20,
                children: [
                  // Tombol untuk Guru
                  buildOption(
                    context,
                    icon: Icons.person_2,
                    label: 'Guru',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TeacherLoginScreen(),
                        ),
                      );
                    },
                  ),
                  // Tombol untuk Siswa
                  buildOption(
                    context,
                    icon: Icons.person_3,
                    label: 'Siswa',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentLoginScreen(),
                        ),
                      );
                    },
                  ),
                  // Tombol untuk Admin
                  buildOption(
                    context,
                    icon: Icons.admin_panel_settings,
                    label: 'Admin',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminLoginPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
            ),
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