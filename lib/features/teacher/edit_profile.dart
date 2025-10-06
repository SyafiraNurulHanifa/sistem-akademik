import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_client.dart'; // ⬅️ nambah: panggil API

class EditTeacherProfile extends StatefulWidget {
  final String nama;
  final String email;
  final String nip;
  final String jabatan;
  final String tahunMasuk;
  final String? avatar; // ✅ tambah avatar lama

  const EditTeacherProfile({
    super.key,
    required this.nama,
    required this.email,
    required this.nip,
    required this.jabatan,
    required this.tahunMasuk,
    this.avatar,
  });

  @override
  State<EditTeacherProfile> createState() => _EditTeacherProfileState();
}

class _EditTeacherProfileState extends State<EditTeacherProfile> {
  late TextEditingController namaController;
  late TextEditingController emailController;
  late TextEditingController nipController;
  late TextEditingController jabatanController;
  late TextEditingController tahunMasukController;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.nama);
    emailController = TextEditingController(text: widget.email);
    nipController = TextEditingController(text: widget.nip);
    jabatanController = TextEditingController(text: widget.jabatan);
    tahunMasukController = TextEditingController(text: widget.tahunMasuk);

    if (widget.avatar != null && widget.avatar!.trim().isNotEmpty) {
      final f = File(widget.avatar!);
      if (f.existsSync()) {
        _imageFile = f; // ✅ tampilkan foto lama kalau local file
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    // Kirim ke API (multipart). Endpoint: PUT/POST /api/guru/profile (di route kamu pakai PUT).
    // Karena ApiClient.multipartAuth hanya POST, kita pakai POST ke endpoint yang sama.
    // Kalau backend-mu minta PUT, boleh tambahkan endpoint khusus di backend atau bikin method put multipart.
    setState(() => _saving = true);

    try {
      final fields = <String, String>{
        "nama": namaController.text.trim(),
        "email": emailController.text.trim(),
        "nip": nipController.text.trim(),
        "jabatan": jabatanController.text.trim(),
        "tahun_masuk": tahunMasukController.text.trim(),
      };

      final res = await ApiClient.multipartAuth(
        "guru/profile", // ⬅️ sesuaikan jika backendmu require PUT, tapi POST ini sering dipakai untuk multipart update
        fields: fields,
        fileField: _imageFile != null ? "foto_profil" : null,
        file: _imageFile,
      );

      if (res['status'] == 'success') {
        // Ambil data balik (robust ke dua bentuk)
        final d = (res['data'] ?? {}) as Map<String, dynamic>;
        final guru = (d['guru'] ?? d) as Map<String, dynamic>;

        // Foto bisa dikembalikan sebagai path/URL
        final updatedAvatar =
            (guru['foto_profil'] ?? guru['fotoProfil'] ?? widget.avatar);

        if (!mounted) return;
        Navigator.pop(context, {
          'nama': guru['nama'] ?? namaController.text,
          'email': guru['email'] ?? emailController.text,
          'nip': (guru['nip'] ?? nipController.text)?.toString(),
          'jabatan': guru['jabatan'] ?? jabatanController.text,
          'tahunMasuk':
              (guru['tahun_masuk'] ??
                      guru['tahunMasuk'] ??
                      tahunMasukController.text)
                  .toString(),
          'avatar': _imageFile != null ? _imageFile!.path : updatedAvatar,
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Gagal menyimpan'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan. Coba lagi.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
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
                    onTap: _pickImage,
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
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : null,
                        child: _imageFile == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 40,
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

            // FORM
            _buildField("Nama", namaController),
            _buildField("Email", emailController),
            _buildField("NIP", nipController),
            _buildField("Jabatan", jabatanController),
            _buildField("Tahun Masuk", tahunMasukController),

            const SizedBox(height: 20),

            // BUTTON SIMPAN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B5ED7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Simpan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Masukkan $label...",
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
