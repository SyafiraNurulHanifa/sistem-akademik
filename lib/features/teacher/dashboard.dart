import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/teacher_api.dart';
import 'attendance.dart';
import 'profile.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String nama = "Teacher";
  String? avatarPath;

  String email = "john.doe@example.com";
  String nip = "1234567890";
  String jabatan = "Guru Matematika";
  String tahunMasuk = "2020";

  @override
  void initState() {
    super.initState();
    _loadTeacherProfile();
  }

  Future<void> _loadTeacherProfile() async {
    try {
      final teacher = await TeacherApi.profile();
      if (teacher != null && mounted) {
        setState(() {
          nama = teacher.nama;
          email = teacher.email;
        });
      }
    } catch (e) {
      debugPrint("Gagal load profil guru: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ======= HEADER =======
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF27C2A0),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(300),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeacherProfile(
                            initialData: {
                              'nama': nama,
                              'avatar': avatarPath,
                              'email': email,
                              'nip': nip,
                              'jabatan': jabatan,
                              'tahunMasuk': tahunMasuk,
                            },
                          ),
                        ),
                      );

                      if (result != null && result is Map) {
                        setState(() {
                          nama = result['nama'] ?? nama;
                          email = result['email'] ?? email;
                          nip = result['nip'] ?? nip;
                          jabatan = result['jabatan'] ?? jabatan;
                          tahunMasuk = result['tahunMasuk'] ?? tahunMasuk;
                          avatarPath = result['avatar'] ?? avatarPath;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF27C2A0),
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: avatarPath != null
                            ? FileImage(File(avatarPath!))
                            : null,
                        child: avatarPath == null
                            ? const Icon(
                                Icons.person,
                                size: 55,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),

            // ======= WELCOME CARD =======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B5ED7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Welcome, $nama!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Have a great day teaching!",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ======= GRID MENU =======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _DashboardItem(
                    icon: Icons.checklist,
                    label: "Attendance",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TeacherAttendance(),
                        ),
                      );
                    },
                  ),
                  _DashboardItem(
                    icon: Icons.book,
                    label: "Homework",
                    onTap: () {},
                  ),
                  _DashboardItem(
                    icon: Icons.grade,
                    label: "Result",
                    onTap: () {},
                  ),
                  _DashboardItem(
                    icon: Icons.schedule,
                    label: "Exam Routine",
                    onTap: () {},
                  ),
                  _DashboardItem(
                    icon: Icons.event_note,
                    label: "Notice & Events",
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DashboardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DashboardItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFF5FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF0057D8)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
