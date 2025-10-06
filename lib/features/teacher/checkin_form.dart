import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class CheckInForm extends StatefulWidget {
  const CheckInForm({super.key});

  @override
  State<CheckInForm> createState() => _CheckInFormState();
}

class _CheckInFormState extends State<CheckInForm> {
  final String _tanggal = DateTime.now().toString().split(' ')[0]; // yyyy-MM-dd
  String get _waktu =>
      "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";

  File? _foto;
  String? _status; // Hadir / Izin / Sakit / Alpha
  String? _lokasi; // "lat, lng"

  Future<void> _ambilFoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _foto = File(image.path));
  }

  Future<void> _ambilLokasi() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() => _lokasi = "${pos.latitude}, ${pos.longitude}");
  }

  void _submit() {
    if (_status == null || _foto == null || _lokasi == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi semua data")));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Check In berhasil disimpan")));

    // ✅ kirim balik ke halaman Attendance (tanpa foto)
    Navigator.pop(context, {
      'type': 'in', // penting buat nentuin card mana yang update
      'date': _tanggal, // yyyy-MM-dd
      'time': _waktu, // HH:mm
      'status': _status, // Hadir/Izin/Sakit/Alpha
      'location': _lokasi, // "lat, lng"
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text("Check In"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Tanggal & Waktu
          _infoTile(Icons.calendar_today, "Tanggal", _tanggal),
          _infoTile(Icons.access_time, "Waktu", _waktu),
          const SizedBox(height: 16),

          // 2. Foto
          Text("Foto Check In", style: textTheme.titleMedium),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _ambilFoto,
            child: _boxContainer(
              child: _foto == null
                  ? const _BoxEmpty(
                      icon: Icons.camera_alt,
                      text: "Tap untuk ambil foto",
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_foto!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Status
          Text("Status Kehadiran", style: textTheme.titleMedium),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            value: _status,
            items: const [
              DropdownMenuItem(value: "Hadir", child: Text("Hadir")),
              DropdownMenuItem(value: "Izin", child: Text("Izin")),
              DropdownMenuItem(value: "Sakit", child: Text("Sakit")),
              DropdownMenuItem(value: "Alpha", child: Text("Alpha")),
            ],
            onChanged: (val) => setState(() => _status = val),
          ),
          const SizedBox(height: 20),

          // 4. Lokasi
          Text("Lokasi", style: textTheme.titleMedium),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _ambilLokasi,
            child: _boxContainer(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _lokasi == null
                      ? const Center(
                          child: Text(
                            "Tap untuk ambil lokasi",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Image.network(
                          "https://maps.googleapis.com/maps/api/staticmap"
                          "?center=$_lokasi&zoom=15&size=600x300&markers=$_lokasi&key=DUMMY_KEY",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              _lokasi!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.my_location, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 5. Submit
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: const Text(
                "Submit",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boxContainer({required Widget child}) => Container(
    width: double.infinity,
    height: 180,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

class _BoxEmpty extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BoxEmpty({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.grey),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
