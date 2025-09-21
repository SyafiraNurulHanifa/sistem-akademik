import 'package:flutter/material.dart';

class CheckOutForm extends StatelessWidget {
  const CheckOutForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check Out Form"),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Check Out",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Nama
            const TextField(
              decoration: InputDecoration(
                labelText: "Nama",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Lokasi
            const TextField(
              decoration: InputDecoration(
                labelText: "Lokasi",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Jam
            const TextField(
              decoration: InputDecoration(
                labelText: "Jam Check Out",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol submit
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Check Out Submitted (Dummy)"),
                    ),
                  );
                  Navigator.pop(context); // balik ke Attendance
                },
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
