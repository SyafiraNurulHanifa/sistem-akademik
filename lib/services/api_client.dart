import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = "http://10.0.2.2:8000/api";
  // Emulator Android => 10.0.2.2 ; device real => IP Wi-Fi laptop kamu

  static const Duration _timeout = Duration(seconds: 20);

  // -------------------------
  // Helpers
  // -------------------------
  static Map<String, dynamic> _safeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {"status": "error", "message": "Unexpected response"};
    } catch (_) {
      return {"status": "error", "message": "Invalid JSON"};
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // -------------------------
  // Public methods
  // -------------------------

  /// POST tanpa token (login / register)
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final res = await http
        .post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    return _safeJson(res.body);
  }

  /// GET dengan token
  static Future<Map<String, dynamic>> getAuth(String endpoint) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    final res = await http
        .get(
          url,
          headers: {
            "Content-Type": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
        )
        .timeout(_timeout);
    return _safeJson(res.body);
  }

  /// POST dengan token (JSON)
  static Future<Map<String, dynamic>> postAuth(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    final res = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    return _safeJson(res.body);
  }

  /// PUT dengan token (JSON)
  static Future<Map<String, dynamic>> putAuth(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    final res = await http
        .put(
          url,
          headers: {
            "Content-Type": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    return _safeJson(res.body);
  }

  /// Multipart dengan token (untuk upload foto, dll)
  ///
  /// [fields] = field teks biasa (nama, email, dsb)
  /// [fileField] = nama field file di backend (mis. "foto_profil")
  /// [file] = File yang mau diupload
  static Future<Map<String, dynamic>> multipartAuth(
    String endpoint, {
    Map<String, String>? fields,
    String? fileField,
    File? file,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/$endpoint');

    final req = http.MultipartRequest('POST', uri);
    if (token != null) req.headers['Authorization'] = 'Bearer $token';

    // form fields
    if (fields != null && fields.isNotEmpty) {
      req.fields.addAll(fields);
    }

    // file (opsional)
    if (fileField != null && file != null) {
      req.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    }

    final streamed = await req.send().timeout(_timeout);
    final body = await streamed.stream.bytesToString();
    return _safeJson(body);
  }
}
