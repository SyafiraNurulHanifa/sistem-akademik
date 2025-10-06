import 'package:flutter/material.dart';
import 'profile.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentProfile(),
                        ),
                      );
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
                        child: const Icon(
                          Icons.person,
                          size: 55,
                          color: Colors.grey,
                        ),
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
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Welcome, Student!",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Have a great day learning!",
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
                    onTap: () {}, // TODO: arahkan ke halaman attendance student
                  ),
                  _DashboardItem(
                    icon: Icons.book,
                    label: "Homework",
                    onTap: () {}, // TODO: arahkan ke homework
                  ),
                  _DashboardItem(
                    icon: Icons.grade,
                    label: "Result",
                    onTap: () {}, // TODO: arahkan ke result
                  ),
                  _DashboardItem(
                    icon: Icons.schedule,
                    label: "Exam Routine",
                    onTap: () {}, // TODO: arahkan ke exam routine
                  ),
                  _DashboardItem(
                    icon: Icons.event_note,
                    label: "Notice & Events",
                    onTap: () {}, // TODO: arahkan ke notice/events
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
