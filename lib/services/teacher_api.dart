import 'package:shared_preferences/shared_preferences.dart';
import '../models/teacher.dart';
import 'api_client.dart';

class TeacherApi {
  /// Login Guru
  static Future<Teacher?> login(String email, String password) async {
    final data = await ApiClient.post("guru/login", {
      "email": email,
      "password": password,
    });

    if (data['status'] == 'success' && data['data'] != null) {
      final guruJson = data['data']['guru'];
      final teacher = Teacher.fromJson(guruJson);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['data']['token']);

      return teacher;
    }
    return null;
  }

  /// Ambil profil guru (contoh endpoint auth)
  static Future<Teacher?> profile() async {
    final data = await ApiClient.getAuth("guru/profile");
    if (data['status'] == 'success' && data['data'] != null) {
      return Teacher.fromJson(data['data']);
    }
    return null;
  }
}
