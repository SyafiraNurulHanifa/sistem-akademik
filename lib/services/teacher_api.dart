import 'package:shared_preferences/shared_preferences.dart';
import '../models/teacher.dart';
import 'api_client.dart';

class TeacherApi {
  /// Login Guru — fleksibel ke 2 bentuk respons:
  /// A) {status:'success', data:{guru:{}, token:'...'}}
  /// B) {token:'...', user:{...}}
  static Future<Teacher?> login(String email, String password) async {
    final data = await ApiClient.post("guru/login", {
      "email": email,
      "password": password,
    });

    // Ambil token + user/guru secara fleksibel
    final token = data['data']?['token'] ?? data['token'];
    final user = data['data']?['guru'] ?? data['guru'] ?? data['user'];

    if (token != null && user is Map<String, dynamic>) {
      final teacher = Teacher.fromJson(user);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return teacher;
    }

    return null;
  }

  /// Ambil profil guru — GET /api/guru/profile
  static Future<Teacher?> profile() async {
    final data = await ApiClient.getAuth("guru/profile");

    // Beberapa backend mengembalikan:
    // A) {status:'success', data:{...}}
    // B) {nama:..., email:...}
    if (data['status'] == 'success' && data['data'] is Map<String, dynamic>) {
      return Teacher.fromJson(data['data'] as Map<String, dynamic>);
    }
    if (data.isNotEmpty && data['status'] != 'error') {
      return Teacher.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  /// Update profil guru — PUT /api/guru/profile (JSON, tanpa file)
  static Future<bool> updateProfile({
    required String nama,
    required String email,
    String? nip,
    String? jabatan,
    String? tahunMasuk,
    String? telepon,
    String? mapel,
  }) async {
    final payload = <String, dynamic>{
      "nama": nama,
      "email": email,
      if (nip != null && nip.isNotEmpty) "nip": nip,
      if (jabatan != null && jabatan.isNotEmpty) "jabatan": jabatan,
      if (tahunMasuk != null && tahunMasuk.isNotEmpty)
        "tahun_masuk": tahunMasuk,
      if (telepon != null && telepon.isNotEmpty) "telepon": telepon,
      if (mapel != null && mapel.isNotEmpty) "mapel": mapel,
    };

    final res = await ApiClient.putAuth("guru/profile", payload);

    // ApiClient sudah menganggap 200/204 empty body sebagai {"status":"success"}
    if (res["status"] == "success") return true;

    // Kalau backend balas JSON lain yang bukan error, anggap sukses
    if (res["status"] != "error") return true;

    return false;
  }
}
