import 'package:flutter/material.dart';
import 'choose_option.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChooseOptionScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Lengkungan hijau kiri atas
            Positioned(
              top: -310, // geser keluar layar ke atas
              left: -180, // geser keluar layar ke kiri
              child: Container(
                width: 400, // lebih besar biar setengahnya doang yg kelihatan
                height: 400,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 0, 191, 166),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Lengkungan biru bawah
            Positioned(
              bottom: -330, // geser keluar layar
              left: -50,
              right: -50,
              child: Container(
                width:
                    MediaQuery.of(context).size.width *
                    1.5, // lebih lebar biar nutup
                height: 450,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Logo di tengah
            Center(
              child: Image.asset(
                'assets/icons/logo.png',
                width: MediaQuery.of(context).size.width * 0.6, // rasio logo
              ),
            ),
          ],
        ),
      ),
    );
  }
}
