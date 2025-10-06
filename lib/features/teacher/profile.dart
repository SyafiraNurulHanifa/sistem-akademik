import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/api_client.dart'; // ⬅️ nambah: panggil API
import 'edit_profile.dart';

class TeacherProfile extends StatefulWidget {
  final Map<String, dynamic>? initialData; // ✅ data dari luar (misal dashboard)

  const TeacherProfile({super.key, this.initialData});

  @override
  State<TeacherProfile> createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile> {
  late String nama;
  late String email;
  late String nip;
  late String jabatan;
  late String tahunMasuk;
  String? avatar;

  bool _loading = false; // ⬅️ untuk load profil dari API

  @override
  void initState() {
    super.initState();
    // ✅ pakai initialData dulu biar UI langsung tampil
    nama = widget.initialData?['nama'] ?? "John Doe";
    email = widget.initialData?['email'] ?? "john.doe@example.com";
    nip = widget.initialData?['nip'] ?? "1234567890";
    jabatan = widget.initialData?['jabatan'] ?? "Guru Matematika";
    tahunMasuk = widget.initialData?['tahunMasuk'] ?? "2020";
    avatar = widget.initialData?['avatar'];

    // Lalu fetch dari API agar sinkron dengan server (tidak ubah tampilan)
    _fetchProfileFromApi();
  }

  Future<void> _fetchProfileFromApi() async {
    try {
      setState(() => _loading = true);
      final res = await ApiClient.getAuth("guru/profile");

      // Backend kamu bentuk respons: { status, message, data: {...} }
      final data = (res['data'] ?? {}) as Map<String, dynamic>;

      // Robust ke variasi key
      setState(() {
        nama = (data['nama'] ?? nama) as String;
        email = (data['email'] ?? email) as String;
        nip = (data['nip'] ?? nip)?.toString() ?? nip;
        jabatan = (data['jabatan'] ?? jabatan) as String;
        tahunMasuk = (data['tahun_masuk'] ?? data['tahunMasuk'] ?? tahunMasuk)
            .toString();

        // foto_profil bisa path relatif / URL; simpan seadanya
        final foto = data['foto_profil'] ?? data['fotoProfil'];
        if (foto != null && (foto as String).trim().isNotEmpty) {
          avatar = foto;
        }
      });
    } catch (_) {
      // cukup diam atau kasih snack kecil (opsional)
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  ImageProvider? _avatarProvider() {
    if (avatar == null || avatar!.trim().isEmpty) return null;

    // Kalau local file path
    final f = File(avatar!);
    if (f.existsSync()) return FileImage(f);

    // Kalau URL (http/https) atau path storage yang kamu serve via /storage
    if (avatar!.startsWith('http')) {
      return NetworkImage(avatar!);
    }

    // Path relatif => coba asumsikan via /storage/...
    return NetworkImage('http://10.0.2.2:8000/storage/$avatar');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ✅ biar bisa intercept back
      onWillPop: () async {
        Navigator.pop(context, {
          'nama': nama,
          'email': email,
          'nip': nip,
          'jabatan': jabatan,
          'tahunMasuk': tahunMasuk,
          'avatar': avatar,
        });
        return false; // jangan pakai pop default
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ===== HEADER =====
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
                        backgroundImage: _avatarProvider(),
                        child: _avatarProvider() == null
                            ? const Icon(
                                Icons.person,
                                size: 55,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 70),

              // (opsional) indikator kecil saat sync profil—tidak ubah layout
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),

              // ===== DATA PROFILE =====
              _buildInfoTile(Icons.person, "Nama", nama),
              _buildInfoTile(Icons.email, "Email", email),
              _buildInfoTile(Icons.badge, "NIP", nip),
              _buildInfoTile(Icons.work, "Jabatan", jabatan),
              _buildInfoTile(Icons.date_range, "Tahun Masuk", tahunMasuk),

              const SizedBox(height: 20),

              // ===== BUTTON EDIT =====
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
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditTeacherProfile(
                            nama: nama,
                            email: email,
                            nip: nip,
                            jabatan: jabatan,
                            tahunMasuk: tahunMasuk,
                            avatar: avatar, // ✅ ikut dikirim
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
                          avatar = result['avatar'] ?? avatar;
                        });
                      }
                    },
                    child: const Text(
                      "Edit",
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
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF27C2A0)),
          title: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
